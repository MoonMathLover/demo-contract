// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// Lock solc verion since the codehash of Verifier is used by the DemoDay contract

import {Groth16Verifier} from "../lib/fisher-yates/testData/Main_50-50_zkPlayground_groth16.verifier.sol";

contract Verifier is Groth16Verifier {}
