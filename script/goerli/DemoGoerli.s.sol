// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DeployDemo} from "../Demo.s.sol";

contract DemoGoerli is DeployDemo {
    uint256 private chainId;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        internal functions
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function _initFork() internal override {
        chainId = vm.createFork("goerli");
    }

    function _selectFork() internal override {
        vm.selectFork(chainId);
    }
}
