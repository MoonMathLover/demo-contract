// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

struct TypeCounter {
    uint256 value;
}

library LibCounter {
    function current(TypeCounter storage s) internal view returns (uint256) {
        return s.value;
    }

    function increase(TypeCounter storage s) internal returns (uint256) {
        unchecked {
            s.value += 1;
        }
        return s.value;
    }
}
