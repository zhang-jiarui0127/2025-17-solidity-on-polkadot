// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract LogicContract {
    
    uint public counter;   // 插槽0
    address public admin;  // 插槽1

    // 构造函数仅在直接部署时设置逻辑合约自己的状态
    constructor() {
        admin = msg.sender;
    }

    function increment() public returns (uint) {
        counter += 1;
        return counter;
    }
}
