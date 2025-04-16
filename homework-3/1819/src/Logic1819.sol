// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Logic1819 {
    // 计数器状态变量（注意：实际存储在代理合约中）
    uint256 public counter;

    // 增加计数器的函数
    function increment() external {
        counter += 1;
    }
}