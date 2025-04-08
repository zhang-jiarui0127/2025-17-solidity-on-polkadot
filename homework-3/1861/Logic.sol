// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 逻辑合约：包含状态修改逻辑
contract Logic {
    uint public count; // 存储布局必须与代理合约完全一致！

    function increment() public {
        count += 1;
    }
}