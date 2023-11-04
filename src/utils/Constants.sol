// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Constants {
    /// @dev default value of stage
    uint8 constant STAGE_0_DEFAULT = 0;
    /// @dev commit stage for dev team to commit `verifier` and `future block number`
    uint8 constant STAGE_1_COMMIT = 1;
    /// @dev user stage for user to purchase lootbox
    uint8 constant STAGE_2_USER = 2;
    /// @dev reveal stage for dev team to reveal `verifier` and `randomness`
    uint8 constant STAGE_3_REVEAL = 3;
    /// @dev unlock lootbox result
    uint8 constant STAGE_4_UNLOCK = 4;
}
