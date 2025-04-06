// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Logic.sol";
import "../src/Proxy.sol";

contract ProxyTest is Test {
    Logic public logic;
    Proxy public proxy;

    function setUp() public {
        logic = new Logic();
        proxy = new Proxy();
    }

    function testDelegateCallUpdatesProxyState() public {
        // 初始状态验证
        assertEq(proxy.count(), 0, "Proxy count should start at 0");
        assertEq(logic.count(), 0, "Logic count should start at 0");

        // 通过代理调用逻辑合约的 increment
        proxy.delegateCallIncrement(address(logic));

        // 验证代理合约状态更新，逻辑合约状态不变
        assertEq(proxy.count(), 1, "Proxy count should be 1 after delegatecall");
        assertEq(logic.count(), 0, "Logic count should remain 0");
    }

    function testStorageSlotConsistency() public {
        assertEq(logic.count(), 0, "Logic count should start at 0");
        logic.increment();
        assertEq(logic.count(), 1, "Logic count should be 1");
        assertEq(proxy.count(), 0, "Proxy count should start at 0");
        proxy.delegateCallIncrement(address(logic));
        assertEq(proxy.count(), 1, "Proxy count should be 1 after delegatecall");
        proxy.delegateCallIncrement(address(logic));
        assertEq(proxy.count(), 2, "Proxy count should be 2 after delegatecall");
        


    }
}