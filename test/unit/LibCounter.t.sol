// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../Base.sol";

contract TestLibCounter is BaseTest {
    using LibCounter for TypeCounter;

    TypeCounter internal _counter;

    function testCounter() external {
        assertEq(_counter.increase(), 1);
        assertEq(_counter.current(), 1);
        assertEq(_counter.increase(), 2);
        assertEq(_counter.current(), 2);
        assertEq(_counter.increase(), 3);
        assertEq(_counter.current(), 3);
    }
}
