// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@forge-std/Test.sol";
import "../src/Attestor.sol";

// TODO some more work here...
contract CounterTest is Test {
    Attestor public attestor;
    function setUp() public {
       counter = new Attestor("Test", cid);
       counter.setNumber(0);
    }

    function testIncrement() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testSetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
