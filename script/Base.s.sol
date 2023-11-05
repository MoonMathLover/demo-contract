// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

abstract contract BaseScript is Script {
    address internal deployerAddr;
    uint256 private privateKey;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        modifiers
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    modifier broadcast() {
        vm.startBroadcast(privateKey);
        _;
        vm.stopBroadcast();
    }

    modifier fork() {
        _;
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        external functions
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function setUp() external virtual {
        privateKey = vm.envUint("PRIVATE_KEY");
        deployerAddr = vm.addr(privateKey);
    }

    function run() external virtual {}

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        internal functions
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function _initFork() internal virtual;

    function _selectFork() internal virtual;
}
