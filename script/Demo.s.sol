// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BaseScript, console} from "./Base.s.sol";
import {DemeDay} from "../src/DemoDay.sol";

abstract contract DeployDemo is BaseScript {
    DemeDay private _demo;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        external functions
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function run() external override {
        _deployDemoDay();
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        private functions
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function _deployDemoDay() private fork broadcast {
        _demo = new DemeDay(deployerAddr);
        console.logString("deploy DemoDay:");
        console.logAddress(address(_demo));
    }
}
