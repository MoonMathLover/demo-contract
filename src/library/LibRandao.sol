// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// import {Errors} from "./Errors.sol";
import {Events} from "./Events.sol";

struct TypeRandao {
    uint256 blockNumber;
    uint256 randomness;
}

library LibRandao {
    function propose(
        TypeRandao storage s,
        uint256 duration,
        uint256 futureBlockNumber
    ) internal {
        uint256 bn = block.number;
        uint256 end = bn + duration;
        require(end < futureBlockNumber, "propose invalid block number");

        s.blockNumber = futureBlockNumber;
        emit Events.RandaoPropose(bn, futureBlockNumber);
    }

    function reveal(TypeRandao storage s) internal {
        uint256 bn = block.number;
        require(s.blockNumber < bn, "reveal randomness in lock time");

        uint256 prevrandao = block.prevrandao;
        s.randomness = prevrandao;
        emit Events.RandaoReveal(bn, prevrandao);
    }
}
