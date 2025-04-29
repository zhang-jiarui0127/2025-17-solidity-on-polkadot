// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LogicContract.sol";
import "./ProxyContract.sol";

contract DelegatecallTest {
    LogicContract public logicContract;
    ProxyContract public proxyContract;
    
    constructor() {
        // 部署逻辑合约
        logicContract = new LogicContract();
        
        // 部署代理合约，并传入逻辑合约地址
        proxyContract = new ProxyContract(address(logicContract));
    }
    
    // 测试函数：通过代理合约调用逻辑合约
    function testDelegatecall() external returns (uint256) {
        // 调用代理合约的 callIncrement 函数
        proxyContract.callIncrement();
        
        // 返回更新后的计数器值
        return proxyContract.getCounter();
    }
    
    // 测试函数：直接调用逻辑合约
    function testDirectCall() external {
        // 直接调用逻辑合约的函数
        logicContract.directIncrement();
        
        // 这不会影响代理合约的状态
    }
} 