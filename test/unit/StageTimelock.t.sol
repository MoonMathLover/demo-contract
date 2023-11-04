// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../Base.sol";

contract TestStageTimelock is BaseTest, StageTimelock {
    function testChange() external {
        assertEq(_currentStage(), Constants.STAGE_0_DEFAULT);
        _changeStage(Constants.STAGE_1_COMMIT);
        assertEq(_currentStage(), Constants.STAGE_1_COMMIT);
    }
}
