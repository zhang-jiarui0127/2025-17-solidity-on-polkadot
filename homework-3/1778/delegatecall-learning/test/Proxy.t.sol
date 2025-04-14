// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Logic} from "../src/Logic.sol";
import {Proxy} from "../src/Proxy.sol";

contract ProxyTest is Test {
    Logic logicContract;
    Proxy proxyContract;

    function setUp() public {
        logicContract = new Logic();
        proxyContract = new Proxy(address(logicContract));
    }

    function test_IncrementDelegatecall() public {
        assertEq(proxyContract.counter(), 0, "Initial counter value should be 0");
        assertEq(logicContract.counter(), 0, "Initial counter value should be 0");
        assertEq(proxyContract.incrementDelegatecall(), 1, "Increment should return 1");
        assertEq(proxyContract.counter(), 1, "Counter should be 1 after increment");
        assertEq(logicContract.counter(), 0, "Logic contract counter should remain 0");
    }

    function test_UpdateLogicAddress() public {
        // Create a new Logic contract
        Logic newLogic = new Logic();

        // Update the proxy's logic address to point to the new Logic contract
        proxyContract.updateLogicAddress(address(newLogic));

        // Verify that the proxy's logic address has been updated
        assertEq(proxyContract.logicAddress(), address(newLogic), "Proxy's logic address should be updated");

        // Verify that the new logic contract's counter is 0 and can be incremented
        assertEq(proxyContract.counter(), 0, "New logic contract counter should be 0 initially");
        assertEq(proxyContract.incrementDelegatecall(), 1, "Increment should return 1 on new logic contract");
        assertEq(proxyContract.counter(), 1, "Counter should be 1 after increment on new logic contract");
    }
}
