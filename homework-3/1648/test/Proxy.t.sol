// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test, console} from "forge-std/Test.sol";
import {Proxy} from "../src/Proxy.sol";
import {Logic} from "../src/Logic.sol";

contract ProxyTest is Test {
    Proxy public proxy;
    Logic public logic;

    function setUp() public {
        logic = new Logic();
        proxy = new Proxy(address(logic));
    }

    function test_getCount() public {
        uint256 value = 3;

        proxy.setCount(value);
        assertEq(value, proxy.count());

        // increment
        proxy.increment();
        assertEq(value + 1, proxy.count());
    }
}
