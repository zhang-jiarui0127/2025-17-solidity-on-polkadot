// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// 逻辑合约
contract LogicContract {
    // 状态变量 - 注意这个变量不会在逻辑合约中实际改变
    uint256 public counter;

    // 增加计数器的函数
    function increment() external returns (uint256) {
        counter = counter + 1;
        return counter;
    }
}
