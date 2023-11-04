// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IVerifier} from "../../src/interface/IVerifier.sol";

contract MockVerifier is IVerifier {
    function verify() external pure returns (bool) {
        return true;
    }
}
