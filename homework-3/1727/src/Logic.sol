// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title 逻辑合约
 * @dev 包含通过 delegatecall 执行的业务逻辑
 * 重要：存储布局必须与代理合约兼容
 */
contract Logic {
    // 存储槽 0：计数器
    uint256 public count;

    // 存储槽 1（示例）：所有者（在 increment 中未使用，但显示布局的重要性）
    // address public owner; // 如果代理合约在槽 1 中没有这个，delegatecall 可能会破坏状态

    /**
     * @dev 增加调用合约存储上下文中的 count 变量
     * 当通过代理合约的 delegatecall 调用时，它修改代理合约的 count
     */
    function increment() public {
        count++;
    }

    // 可选：设置计数的函数（用于不同场景）
    function setCount(uint256 _newCount) public {
        count = _newCount;
    }
}