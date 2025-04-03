// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 定义逻辑合约，包含计数器和增加计数器的函数
contract LogicContract {
    // 公共的无符号整数计数器，用于记录调用次数
    uint256 public counter;

    // 外部可调用的函数，用于增加计数器的值
    function increment() external {
        // 每次调用该函数时，计数器的值加 1
        counter++;
    }
}
