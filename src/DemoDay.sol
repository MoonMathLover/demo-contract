// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {SSTORE2} from "../lib/solady/src/utils/SSTORE2.sol";
import {LibString} from "../lib/solady/src/utils/LibString.sol";

import {StageTimelock} from "./StageTimelock.sol";
import {IVerifier} from "./interface/IVerifier.sol";

// library
import {TypeCounter, LibCounter} from "./library/LibCounter.sol";
import {TypeRandao} from "./library/LibRandao.sol";

// utils
import {Constants} from "./utils/Constants.sol";
import {Errors} from "./utils/Errors.sol";
import {Events} from "./utils/Events.sol";

// import "forge-std/console.sol";

contract DemeDay is Ownable, ERC721, StageTimelock {
    using LibCounter for TypeCounter;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        State Variables
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    /// @dev counter for ERC721's tokenId
    TypeCounter internal _counter;

    /// @dev encapsulation of randao randomness
    TypeRandao internal _randao;

    /// @dev verifier address
    address internal _verifierAddr;

    /// @dev verifier codehas
    bytes32 internal _verifierHash;

    /// @dev user contributed swap times
    uint256 internal _userContributeSwapTimes;

    /// @dev
    address internal _pointer;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Constructor
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    constructor(
        address initOwner
    ) ERC721("DEMODAY", "DEMO") Ownable(initOwner) {
        _changeStage(Constants.STAGE_1_COMMIT);
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Stage 1
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    /// @dev `revealRandao` can only be revealed after reaching the future block number
    function commitRandao(
        uint256 futureBlockNumber
    ) external onlyOwner timelock(Constants.STAGE_1_COMMIT) {
        _randao.blockNumber = futureBlockNumber;
        if (_verifierHash != bytes32(0)) {
            _changeStage(Constants.STAGE_2_USER);
        }
    }

    function commitVerifier(
        bytes32 extcodehash
    ) external onlyOwner timelock(Constants.STAGE_1_COMMIT) {
        _verifierHash = extcodehash;
        if (_randao.blockNumber != 0) {
            _changeStage(Constants.STAGE_2_USER);
        }
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Stage 2
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function mint(
        uint8 contribution
    ) external payable timelock(Constants.STAGE_2_USER) {
        _safeMint(msg.sender, _counter.increase());
        unchecked {
            _userContributeSwapTimes += uint256(contribution);
        }
    }

    function batchMint(
        uint8 contributionStart,
        uint8 n
    ) external payable timelock(Constants.STAGE_2_USER) {
        uint8 c = contributionStart;
        for (uint256 i = 0; i < n; i++) {
            _safeMint(msg.sender, _counter.increase());
            unchecked {
                _userContributeSwapTimes += uint256(c);
            }
            c++;
        }
    }

    function closeSales() external onlyOwner timelock(Constants.STAGE_2_USER) {
        _changeStage(Constants.STAGE_3_REVEAL);
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Stage 3
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function revealRandaoForTest(
        uint256 randomness
    ) external onlyOwner timelock(Constants.STAGE_3_REVEAL) {
        _randao.randomness = randomness;

        if (_verifierAddr != address(0)) {
            _changeStage(Constants.STAGE_4_UNLOCK);
        }
    }

    function revealRandao()
        external
        onlyOwner
        timelock(Constants.STAGE_3_REVEAL)
    {
        require(
            _randao.blockNumber < block.number,
            "reveal randomness in lock time"
        );

        _randao.randomness = block.prevrandao;

        if (_verifierAddr != address(0)) {
            _changeStage(Constants.STAGE_4_UNLOCK);
        }
    }

    function revealVerifier(
        address addr
    ) external onlyOwner timelock(Constants.STAGE_3_REVEAL) {
        // console.log("revealVerifier: addr:", addr);
        // console.log("revealVerifier: addr.codehash:");
        // console.logBytes32(addr.codehash);
        // console.log("revealVerifier: _verifierHash:");
        // console.logBytes32(_verifierHash);
        // console.log("revealVerifier: pre addr.codehash == _verifierHash");
        require(addr.codehash == _verifierHash);
        // console.log("revealVerifier: post addr.codehash == _verifierHash");
        _verifierAddr = addr;

        if (_randao.randomness != 0) {
            _changeStage(Constants.STAGE_4_UNLOCK);
        }
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Stage 4STAGE_5_FINISHED
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function unlock(
        bytes calldata data
    ) external onlyOwner timelock(Constants.STAGE_4_UNLOCK) {
        _pointer = SSTORE2.write(data);
        _changeStage(Constants.STAGE_5_FINISHED);
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        View functions
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function stage() external view returns (uint8) {
        return _currentStage();
    }

    function randaoBlockNumber() public view returns (uint256) {
        return _randao.blockNumber;
    }

    function verifierCodeHash() public view returns (bytes32) {
        return _verifierHash;
    }

    function mintCounter() public view returns (uint256) {
        return _counter.current();
    }

    function userContributeSwapTimes() external view returns (uint256) {
        return _userContributeSwapTimes;
    }

    function randaoRandomness() external view returns (uint256) {
        return _randao.randomness;
    }

    function verifier() external view returns (address) {
        return _verifierAddr;
    }

    function verify(
        uint[2] calldata pA,
        uint[2][2] calldata pB,
        uint[2] calldata pC,
        uint256 extraRounds,
        uint256[50] calldata originArray,
        uint256[50] calldata afterShuffleArray
    ) external view returns (bool) {
        uint256 size = originArray.length;
        require(
            size == afterShuffleArray.length,
            "original and afterShuffle array must be of same size"
        );
        require(size == 50, "array size must be 50");

        uint256[102] memory pubSignals;
        {
            // avoid stack too deep
            pubSignals[0] = _randao.randomness;
            pubSignals[1] = extraRounds;
            uint256 originIndex = 2;
            uint256 afterIndex = originIndex + 50;
            for (uint256 i = 0; i < size; ) {
                pubSignals[originIndex + i] = originArray[i];
                pubSignals[afterIndex + i] = afterShuffleArray[i];
                unchecked {
                    ++i;
                }
            }
        }
        return IVerifier(_verifierAddr).verifyProof(pA, pB, pC, pubSignals);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory ret) {
        uint256 start = (tokenId - 1) * 32;
        uint256 end = start + 32;
        uint256 uri = abi.decode(SSTORE2.read(_pointer, start, end), (uint256));
        ret = LibString.toString(uri);
    }
}
