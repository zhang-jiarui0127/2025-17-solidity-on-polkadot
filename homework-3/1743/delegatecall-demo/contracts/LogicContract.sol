// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract LogicContract {
    // 状态变量
    uint256 public dataValue;
    address public owner;

    // 每次调用增加1的函数
    function increment() public returns (uint256) {
        dataValue += 1;
        return dataValue;
    }

    // 初始化函数
    function initialize() public {
        // 确保只能初始化一次
        require(owner == address(0), "Already initialized");
        owner = msg.sender;
    }
}
