// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BaseScript, console} from "./Base.s.sol";
import {Verifier} from "../src/Verifier.sol";

abstract contract DeployVerifier is BaseScript {
    Verifier private _verifier;

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        external functions
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function run() external override {
        _deployVerifier();
    }

    /** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
        private functions
    ***** ***** ***** ***** ***** ***** ***** ***** ***** *****  */
    function _deployVerifier() private fork broadcast {
        _verifier = new Verifier();
        console.logString("deploy verifier:");
        console.logAddress(address(_verifier));
        console.log("codehash:");
        console.logBytes32(address(_verifier).codehash);
    }
}
