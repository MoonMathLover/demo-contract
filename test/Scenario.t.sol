// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Base.sol";

contract TestScenario is BaseTest {
    using stdJson for string;

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
        assertEq(_demo.balanceOf(_user.addr), 50);
        assertEq(_demo.userContributeSwapTimes(), 1275);
        assertEq(_demo.stage(), Constants.STAGE_3_REVEAL);
    }

    function testStage_3() external {
        _stage_1_Operation();
        _stage_2_Operation();
        _stage_3_Operation();
        assertEq(_demo.verifier(), address(_verifier));
        assertEq(_demo.randaoRandomness(), 2664828619369171456);
        assertEq(_demo.stage(), Constants.STAGE_4_UNLOCK);
    }

    function testStage_4() external {
        _stage_1_Operation();
        _stage_2_Operation();
        _stage_3_Operation();
        _stage_4_Operation();
        assertEq(_demo.tokenURI(1), "48");
        assertEq(_demo.tokenURI(2), "8");
        assertEq(_demo.tokenURI(3), "11");
        assertEq(_demo.stage(), Constants.STAGE_0_DEFAULT);
    }

    function _stage_1_Operation() private {
        vm.roll(1000); // block.number = 1000
        vm.startPrank(_admin.addr);
        _demo.commitRandao(5000);
        _demo.commitVerifier(_verifierCodehash);
        vm.stopPrank();
    }

    function _stage_2_Operation() private {
        vm.startPrank(_user.addr);
        // mint 50 token
        for (uint256 i = 1; i <= 50; i++) {
            _demo.mint(uint8(i));
        }
        vm.stopPrank();

        vm.startPrank(_admin.addr);
        _demo.closeSales();
        vm.stopPrank();
    }

    function _stage_3_Operation() private {
        vm.roll(6000); // block.number = 6000
        vm.prevrandao(bytes32(uint256(2664828619369171456))); // block.prevrandao = 2664828619369171456
        vm.startPrank(_admin.addr);
        _demo.revealRandao(2664828619369171456);
        _demo.revealVerifier(address(_verifier));
        vm.stopPrank();
    }

    function _stage_4_Operation() private {
        // tokenURI data
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/testdata/unlock.json");
        string memory json = vm.readFile(path);
        bytes memory data = json.readBytes(".encode");

        vm.startPrank(_admin.addr);
        _demo.unlock(data);
        vm.stopPrank();
    }
}
