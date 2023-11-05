// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DeployDemo} from "../Demo.s.sol";

contract Demo is DeployDemo {
    // instantiate abstract contract
    function _initFork() internal override {
    }

    function _selectFork() internal override {
    }
}
