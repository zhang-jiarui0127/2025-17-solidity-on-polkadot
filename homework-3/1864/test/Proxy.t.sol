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
        // 检查存储槽位是否一致
        uint256 proxySlot0;
        assembly {
            proxySlot0 := sload(0)
        }
        assertEq(proxySlot0, 0, "Proxy slot 0 should be 0 initially");

        // 调用后再次检查
        proxy.delegateCallIncrement(address(logic));
        assembly {
            proxySlot0 := sload(0)
        }
        assertEq(proxySlot0, 1, "Proxy slot 0 should be 1 after delegatecall");
    }
}