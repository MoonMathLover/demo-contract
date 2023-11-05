// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DeployDemo} from "../Demo.s.sol";

contract DemoGoerli is DeployDemo {
    uint256 private forkId;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        internal functions
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function _initFork() internal override {
        forkId = vm.createFork("goerli");
    }

    function _selectFork() internal override {
        vm.selectFork(forkId);
    }
}
