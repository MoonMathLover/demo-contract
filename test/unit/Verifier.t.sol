// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../Base.sol";

contract TestVerifier is BaseTest {
    using stdJson for string;

    function testVerifier() external {
        uint256[2] memory a;
        uint256[2][2] memory b;
        uint256[2] memory c;
        uint256[102] memory signals;
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
            for (uint256 i; i < 102; ++i) {
                signals[i] = pubSignals[i];
            }
        }
        assertEq(true, _verifier.verifyProof(a, b, c, signals));
    }
}
