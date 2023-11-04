// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// test framework
import "forge-std/Test.sol";

// library
import {Constants} from "../src/utils/Constants.sol";
import {Events} from "../src/utils/Events.sol";
import {TypeCounter, LibCounter} from "../src/library/LibCounter.sol";
import {TypeRandao, LibRandao} from "../src/library/LibRandao.sol";

// source
import {DemeDay} from "../src/DemoDay.sol";
import {StageTimelock} from "../src/StageTimelock.sol";
import {MockVerifier} from "./mock/MockVerifier.sol";

contract BaseTest is Test {
    DemeDay internal _demo;
    MockVerifier internal _verifier;
    bytes32 internal _verifierCodehash;

    Account internal _admin;
    Account internal _user;

    function setUp() public virtual {
        // user setup
        _admin = makeAccount("ADMIN");
        _user = makeAccount("USER");

        // deploy contract
        _demo = new DemeDay(_admin.addr);
        _verifier = new MockVerifier();
        _verifierCodehash = address(_verifier).codehash;
    }
}
