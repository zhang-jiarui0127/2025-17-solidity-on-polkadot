// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LogicContract {
    uint public counter;
    
    // 这个函数会被代理合约通过 delegatecall 调用
    function increment() external {
        counter += 1;
    }
    
    // 获取当前计数器值
    function getCounter() external view returns (uint) {
        return counter;
    }
}