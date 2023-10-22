// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../Base.sol";

contract TestRandao is BaseTest {
    using LibRandao for TypeRandao;

    TypeRandao private s;
    uint256 duration = 100;

    function testPropose() external {
        vm.roll(1000); // block.number = 1000

        vm.expectEmit(true, true, true, true);
        emit Events.RandaoPropose(block.number, 2000);
        s.propose(duration, 2000);
    }

    function testReveal() external {
        vm.roll(2100); // block.number = 2100
        vm.prevrandao(bytes32(uint256(1234))); // block.prevrandao = 1234

        vm.expectEmit(true, true, true, true);
        emit Events.RandaoReveal(2100, 1234);
        s.reveal();
    }
}
