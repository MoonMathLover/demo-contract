// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Constants} from "./library/Constants.sol";
import {TypeCounter, LibCounter} from "./library/LibCounter.sol";
import {TypeRandao, LibRandao} from "./library/LibRandao.sol";
import {StageTimelock} from "./StageTimelock.sol";

contract DemeDay is Ownable, ERC721, StageTimelock {
    using LibCounter for TypeCounter;
    using LibRandao for TypeRandao;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        State Variables
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    TypeCounter internal _counter;
    address internal _verifier;
    uint256 internal _userContributeSwapTimes;
    TypeRandao internal _randao;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Constructor
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    constructor(
        address initOwner
    ) ERC721("DEMODAY", "DEMO") Ownable(initOwner) {}

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        User-facing external function
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    /// @dev Stage 3
    function mint(
        uint8 contribution
    ) external timelock(Constants.USER_OPERATION) {
        _safeMint(msg.sender, _counter.increase());
        unchecked {
            _userContributeSwapTimes += uint256(contribution);
        }
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        Admin external function
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    /// @dev Stage 1
    function propose(
        uint256 duration,
        uint256 futureBlockNumber
    ) external onlyOwner timelock(Constants.PROPOSE_BLOCK_NUMBER) {
        _randao.propose(duration, futureBlockNumber);
        _changeStage(Constants.COMMIT_VERIFIER);
    }

    /// @dev Stage 2
    function commit(address verifier) external onlyOwner {
        _verifier = verifier;
        _changeStage(Constants.USER_OPERATION);
    }

    /// @dev Stage 4
    function revealRandom()
        external
        onlyOwner
        timelock(Constants.REVEAL_RANDOMNESS)
    {
        _randao.reveal();
        _changeStage(Constants.REVEAL_LOOTBOX);
    }
}
