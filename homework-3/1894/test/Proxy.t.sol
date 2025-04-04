// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Logic.sol";
import "../src/Proxy.sol";

contract ProxyTest is Test {
    Logic public logic;
    Proxy public proxy;

    function setUp() public {
        logic = new Logic();
        proxy = new Proxy(address(logic));
    }

    function testIncrementViaProxy() public {
        assertEq(proxy.counter(), 0, "Initial proxy counter should be 0");
        assertEq(logic.counter(), 0, "Initial logic counter should be 0");

        bool success = proxy.incrementProxy();
        assertTrue(success, "Delegatecall should succeed");

        assertEq(proxy.counter(), 1, "Proxy counter should be incremented to 1");
        assertEq(logic.counter(), 0, "Logic counter should remain 0");

        success = proxy.incrementProxy();
        assertTrue(success, "Second delegatecall should succeed");

        assertEq(proxy.counter(), 2, "Proxy counter should be incremented to 2");
        assertEq(logic.counter(), 0, "Logic counter should still remain 0");
    }

    function testSetLogicContractAddress() public {
        Logic newLogic = new Logic();
        assertEq(proxy.logicContractAddress(), address(logic), "Initial logic address should be the first one");

        proxy.setLogicContractAddress(address(newLogic));
        assertEq(proxy.logicContractAddress(), address(newLogic), "Logic address should be updated");

        bool success = proxy.incrementProxy();
        assertTrue(success, "Delegatecall with new logic should succeed");

        assertEq(proxy.counter(), 1, "Proxy counter should be incremented to 1 after address change");
        assertEq(logic.counter(), 0, "Old logic counter should remain 0");
        assertEq(newLogic.counter(), 0, "New logic counter should remain 0");
    }
} 