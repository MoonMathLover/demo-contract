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
        assertEq(_demo.randaoRandomness(), 14347092020348981000);
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

    function testRealVerifier() external {
        uint256[2] memory a;
        uint256[2][2] memory b;
        uint256[2] memory c;
        uint256[5001] memory signals;
        {
            // avoid stack too deep
            uint256[] memory pA; // size 2
            uint256[][] memory pB; // [2][2]
            uint256[] memory pC; // size 2
            uint256[] memory pubSignals; // size 5001
            string memory root = vm.projectRoot();
            string memory path = string.concat(
                root,
                "/testData/soliditycalldata.json"
            );
            string memory json = vm.readFile(path);
            pA = json.readUintArray(".pA");
            pB = abi.decode(json.parseRaw(".pB"), (uint256[][]));
            pC = json.readUintArray(".pC");
            pubSignals = json.readUintArray(".pubSignals");

            a[0] = pA[0];
            a[1] = pA[1];
            b[0][0] = pB[0][0];
            b[0][1] = pB[0][1];
            b[1][0] = pB[1][0];
            b[1][1] = pB[1][1];
            c[0] = pC[0];
            c[1] = pC[1];
            for (uint256 i; i < 5001; ++i) {
                signals[i] = pubSignals[i];
            }
        }
        assertEq(true, _realVerifier.verifyProof(a, b, c, signals));
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
        vm.prevrandao(bytes32(uint256(14347092020348981000))); // block.prevrandao = 14347092020348981000
        vm.startPrank(_admin.addr);
        _demo.revealRandao();
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
