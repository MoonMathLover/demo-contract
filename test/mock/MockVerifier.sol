// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IVerifier} from "../../src/interface/IVerifier.sol";

contract MockVerifier is IVerifier {
    function verifyProof(
        uint[2] calldata /* _pA */,
        uint[2][2] calldata /* _pB */,
        uint[2] calldata /* _pC */,
        uint[102] calldata /* _pubSignals */
    ) external pure returns (bool) {
        return true;
    }
}
