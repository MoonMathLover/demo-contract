// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Events {
    /**
     * LibRandao
     */
    event RandaoPropose(
        uint256 indexed currentBlockNumber,
        uint256 proposeBlockNumber
    );

    event RandaoReveal(uint256 indexed acctualBlockNumber, uint256 randomness);
}
