// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LogicContract.sol";
import "./ProxyContract.sol";

// 测试合约 - 用于验证功能
contract TestContract {
    // 测试delegatecall功能
    function testDelegateCall() public {
        // 1. 部署逻辑合约
        LogicContract logic = new LogicContract();
        
        // 2. 部署代理合约，传入逻辑合约地址
        ProxyContract proxy = new ProxyContract(address(logic));
        
        // 3. 验证初始状态
        require(logic.value() == 0, "Logic initial value should be 0");
        require(proxy.value() == 0, "Proxy initial value should be 0");
        
        // 4. 直接调用逻辑合约的increment
        logic.increment();
        require(logic.value() == 1, "Logic value should be 1 after increment");
        require(proxy.value() == 0, "Proxy value should remain 0");
        
        // 5. 通过代理调用increment
        proxy.increment();
        require(proxy.value() == 1, "Proxy value should be 1 after increment");
        require(logic.value() == 1, "Logic value should remain 1");
        
        // 6. 测试setValue函数
        proxy.setValue(10);
        require(proxy.value() == 10, "Proxy value should be 10");
        require(logic.value() == 1, "Logic value should remain 1");
        
        // 7. 测试fallback功能（如果实现了）
        // 可以通过proxy直接调用logic的任何函数
    }
}