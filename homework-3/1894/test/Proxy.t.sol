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
        // Initial state check
        assertEq(proxy.counter(), 0, "Initial proxy counter should be 0");
        assertEq(logic.counter(), 0, "Initial logic counter should be 0");

        // Call increment through the proxy
        bool success = proxy.incrementProxy();
        assertTrue(success, "Delegatecall should succeed");

        // Verify state changes
        // Proxy's counter should be incremented because delegatecall modifies the caller's storage
        assertEq(proxy.counter(), 1, "Proxy counter should be incremented to 1");
        // Logic's counter should remain unchanged as its storage wasn't directly affected
        assertEq(logic.counter(), 0, "Logic counter should remain 0");

         // Call increment through the proxy again
        success = proxy.incrementProxy();
        assertTrue(success, "Second delegatecall should succeed");

         // Verify state changes again
        assertEq(proxy.counter(), 2, "Proxy counter should be incremented to 2");
        assertEq(logic.counter(), 0, "Logic counter should still remain 0");
    }

    function testSetLogicContractAddress() public {
        Logic newLogic = new Logic();
        assertEq(proxy.logicContractAddress(), address(logic), "Initial logic address should be the first one");

        proxy.setLogicContractAddress(address(newLogic));
        assertEq(proxy.logicContractAddress(), address(newLogic), "Logic address should be updated");

         // Call increment through the proxy using the new logic contract address
        bool success = proxy.incrementProxy();
        assertTrue(success, "Delegatecall with new logic should succeed");

        // Verify state changes - proxy's state is updated
        assertEq(proxy.counter(), 1, "Proxy counter should be incremented to 1 after address change");
        // Old logic contract state is unchanged
        assertEq(logic.counter(), 0, "Old logic counter should remain 0");
        // New logic contract state is unchanged
        assertEq(newLogic.counter(), 0, "New logic counter should remain 0");
    }
} 