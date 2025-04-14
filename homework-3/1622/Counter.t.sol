// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Counter_LogicContract.sol";
import "../src/Counter_ProxyContract.sol";

contract DelegateCallTest is Test {
    LogicContract logic;
    ProxyContract proxy;

    function setUp() public {
        logic = new LogicContract();
        proxy = new ProxyContract();
    }

    function testDelegateCallUpdatesProxyState() public {
        // 初始状态
        assertEq(proxy.count(), 0);
        console.log("Initial Proxy Count:", proxy.count());
        // 通过代理合约调用逻辑合约的 increment 函数
        proxy.delegateIncrement(address(logic));

        // 验证代理合约的状态被更新
        assertEq(proxy.count(), 1);
        console.log("Updated Proxy Count:", proxy.count());
        // 验证逻辑合约的状态未被更新
        assertEq(logic.count(), 0);
        console.log("Updated Proxy Count:", proxy.count());
    }
}