// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract StageTimelock {
    uint8 private $currentStage;

    modifier timelock(uint8 specifiedStage) {
        require($currentStage == specifiedStage);
        _;
    }

    function _currentStage() internal view returns (uint8) {
        return $currentStage;
    }

    function _changeStage(uint8 nextStage) internal {
        $currentStage = nextStage;
    }
}
