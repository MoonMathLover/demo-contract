// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Base.sol";

contract TestScenario is BaseTest {
    // function testScenario() external {

    //     // stage 2
    //     vm.startPrank(_admin.addr);
    //     _demo.commit(address(_verifier));
    //     vm.stopPrank();
    //     assertEq(_demo.stage(), Constants.USER_OPERATION);

    //     // stage 3
    //     vm.startPrank(_user.addr);
    //     _demo.mint(10);
    //     _demo.mint(20);
    //     _demo.mint(30);
    //     vm.stopPrank();

    //     // stage 4
    //     vm.roll(6000);
    //     vm.prevrandao(bytes32(uint256(123456)));
    //     vm.startPrank(_admin.addr);
    //     _demo.revealRandom();
    //     vm.stopPrank();
    //     assertEq(_demo.stage(), Constants.REVEAL_LOOTBOX);
    // }

    function testStage_0() external {
        assertEq(_demo.stage(), Constants.STAGE_1_COMMIT);
    }

    function testStage_1() external {
        _stage_1_Operation();
        assertEq(_demo.stage(), Constants.STAGE_2_USER);
    }

    function testStage_2() external {
        _stage_1_Operation();
        _stage_2_Operation();
        assertEq(_demo.balanceOf(_user.addr), 3);
        assertEq(_demo.userContributeSwapTimes(), 6);
        assertEq(_demo.stage(), Constants.STAGE_3_REVEAL);
    }

    function testStage_3() external {
        _stage_1_Operation();
        _stage_2_Operation();
        _stage_3_Operation();
        assertEq(_demo.verifier(), address(_verifier));
        assertEq(_demo.randaoRandomness(), 123456);
        assertEq(_demo.stage(), Constants.STAGE_4_UNLOCK);
    }

    function _stage_1_Operation() private {
        vm.roll(1000); // block.number = 1000
        vm.startPrank(_admin.addr);
        _demo.commitRandao(0, 5000);
        _demo.commitVerifier(_verifierCodehash);
        vm.stopPrank();
    }

    function _stage_2_Operation() private {
        vm.startPrank(_user.addr);
        _demo.mint(1);
        _demo.mint(2);
        _demo.mint(3);
        vm.stopPrank();

        vm.startPrank(_admin.addr);
        _demo.closeSales();
        vm.stopPrank();
    }

    function _stage_3_Operation() private {
        vm.roll(6000); // block.number = 6000
        vm.prevrandao(bytes32(uint256(123456))); // block.prevrandao = 123456
        vm.startPrank(_admin.addr);
        _demo.revealRandao();
        _demo.revealVerifier(address(_verifier));
        vm.stopPrank();
    }
}
