// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LogicContract {
    // 注意：这个合约不存储任何状态
    // 所有状态变更都会发生在调用者的存储空间中
    
    // 函数：将调用者的存储槽 0 的值加 1
    function increment() external {
        assembly {
            // 加载存储槽 0 的当前值
            let value := sload(0)
            // 值加 1
            value := add(value, 1)
            // 将新值存回存储槽 0
            sstore(0, value)
        }
    }
    
    // 这个函数用于测试，直接调用此函数不会影响代理合约
    function directIncrement() external pure {
        // 这个函数不做任何事情，仅用于测试目的
    }
} 