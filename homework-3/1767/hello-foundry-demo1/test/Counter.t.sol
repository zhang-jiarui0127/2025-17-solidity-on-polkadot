// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {LogicCounter} from "../src/LogicCounter.sol";
import {ProxyCounter} from "../src/ProxyCounter.sol";

contract CounterTest is Test {
    LogicCounter public logic;
    ProxyCounter public proxy;

    function setUp() public {
        logic = new LogicCounter();
        proxy = new ProxyCounter(address(logic));
    }

    function testDirectIncrement() public {
        logic.increment();
        assertEq(logic.number(), 1);
    }

    function testDelegateCallIncrement() public {
        proxy.incrementViaDelegate();

        assertEq(proxy.number(), 1);
        assertEq(logic.number(), 0);
    }
}
