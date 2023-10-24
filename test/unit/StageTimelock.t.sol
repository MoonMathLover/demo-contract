// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../Base.sol";

contract TestStageTimelock is BaseTest, StageTimelock {
    function testChange() external {
        assertEq(_currentStage(), Constants.DEFAULT);
        _changeStage(Constants.PROPOSE_BLOCK_NUMBER);
        assertEq(_currentStage(), Constants.PROPOSE_BLOCK_NUMBER);
    }
}
