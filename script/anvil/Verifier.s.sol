// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DeployVerifier} from "../Verifier.s.sol";

contract Verifier is DeployVerifier {
    // instantiate abstract contract
    function _initFork() internal override {
    }

    function _selectFork() internal override {
    }
}
