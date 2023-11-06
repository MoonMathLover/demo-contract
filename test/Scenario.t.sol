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

    function assertVerifyProof() private {
        uint256[2] memory a;
        uint256[2][2] memory b;
        uint256[2] memory c;
        uint256 extraRounds;
        uint256[50] memory originalArray;
        uint256[50] memory afterShuffleArray;
        {
            // avoid stack too deep
            uint256[] memory pA; // size 2
            uint256[][] memory pB; // [2][2]
            uint256[] memory pC; // size 2
            uint256[] memory pubSignals; // size 102
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
            // pubSignals[0]: entropy
            extraRounds = pubSignals[1];
            uint256 j = 0;
            for (uint256 i = 2; i <= 51; ++i) {
                originalArray[j] = pubSignals[i];
                j++;
            }
            j = 0;
            for (uint256 i = 52; i <= 101; ++i) {
                afterShuffleArray[j] = pubSignals[i];
                j++;
            }
        }
        assertEq(
            true,
            _demo.verify(a, b, c, extraRounds, originalArray, afterShuffleArray)
        );
    }

    function testStage_4() external {
        _stage_1_Operation();
        _stage_2_Operation();
        _stage_3_Operation();
        _stage_4_Operation();
        assertEq(_demo.tokenURI(1), "48");
        assertEq(_demo.tokenURI(2), "8");
        assertEq(_demo.tokenURI(3), "11");
        assertEq(_demo.stage(), Constants.STAGE_5_FINISHED);
        assertVerifyProof();
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
        // mint 50 tokens
        // for (uint256 i = 1; i <= 50; i++) {
        //     _demo.mint(uint8(i));
        // }
        _demo.mint(uint8(1));
        _demo.batchMint(2, 49);
        vm.stopPrank();

        vm.startPrank(_admin.addr);
        _demo.closeSales();
        vm.stopPrank();
    }

    function _stage_3_Operation() private {
        vm.roll(6000); // block.number = 6000
        vm.prevrandao(bytes32(uint256(2664828619369171456))); // block.prevrandao = 2664828619369171456
        vm.startPrank(_admin.addr);
        // _demo.revealRandaoForTest(2664828619369171456);
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
