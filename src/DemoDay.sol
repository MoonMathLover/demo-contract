// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {SSTORE2} from "../lib/solady/src/utils/SSTORE2.sol";
import {LibString} from "../lib/solady/src/utils/LibString.sol";

import {StageTimelock} from "./StageTimelock.sol";
import {IVerifier} from "./interface/IVerifier.sol";

// library
import {TypeCounter, LibCounter} from "./library/LibCounter.sol";
import {TypeRandao, LibRandao} from "./library/LibRandao.sol";

// utils
import {Constants} from "./utils/Constants.sol";
import {Errors} from "./utils/Errors.sol";
import {Events} from "./utils/Events.sol";

contract DemeDay is Ownable, ERC721, StageTimelock {
    using LibCounter for TypeCounter;
    using LibRandao for TypeRandao;

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
    function commitRandao(
        uint256 duration,
        uint256 futureBlockNumber
    ) external onlyOwner timelock(Constants.STAGE_1_COMMIT) {
        _randao.propose(duration, futureBlockNumber);
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
    ) external timelock(Constants.STAGE_2_USER) {
        _safeMint(msg.sender, _counter.increase());
        unchecked {
            _userContributeSwapTimes += uint256(contribution);
        }
    }

    function closeSales() external onlyOwner timelock(Constants.STAGE_2_USER) {
        _changeStage(Constants.STAGE_3_REVEAL);
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Stage 3
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function revealRandao()
        external
        onlyOwner
        timelock(Constants.STAGE_3_REVEAL)
    {
        _randao.reveal();

        if (_verifierAddr != address(0)) {
            _changeStage(Constants.STAGE_4_UNLOCK);
        }
    }

    function revealVerifier(
        address addr
    ) external onlyOwner timelock(Constants.STAGE_3_REVEAL) {
        require(addr.codehash == _verifierHash);
        _verifierAddr = addr;

        if (_randao.randomness != 0) {
            _changeStage(Constants.STAGE_4_UNLOCK);
        }
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Stage 4
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function unlock(
        bytes calldata data
    ) external onlyOwner timelock(Constants.STAGE_4_UNLOCK) {
        _pointer = SSTORE2.write(data);
        _changeStage(Constants.STAGE_0_DEFAULT);
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        View functions
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function stage() external view returns (uint8) {
        return _currentStage();
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

    function verify() external view returns (bool) {
        return IVerifier(_verifierAddr).verify();
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
