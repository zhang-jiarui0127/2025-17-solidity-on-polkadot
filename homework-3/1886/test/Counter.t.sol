// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Logic} from "../src/Counter.sol";
import {Proxy} from "../src/Counter.sol";

contract CounterTest is Test {
    Logic logic;
    Proxy proxy;

    function setUp() public {
        logic = new Logic();
        proxy = new Proxy();
    }

    function testIncrease() public {
        uint256 initialCount = logic.count();
        logic.increase();
        uint256 finalCount = logic.count();
        assertEq(finalCount, initialCount + 1);
    }

    function testGetStorage() public {
        uint256 initialCount = logic.count();
        proxy.callLogic(address(logic), true);
        uint256 finalCount = logic.count();
        assertEq(finalCount, initialCount);

        bytes32 storageValue = proxy.getStorage(0);
        assertEq(uint256(storageValue), initialCount + 1);
    }

    function testGetStorageNotDelegateCall() public {
        uint256 initialCount = logic.count();
        proxy.callLogic(address(logic), false);
        uint256 finalCount = logic.count();
        assertEq(finalCount, initialCount + 1);

        bytes32 storageValue = proxy.getStorage(0);
        assertEq(uint256(storageValue), initialCount);
    }
}
