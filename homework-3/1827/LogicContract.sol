// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LogicContract {
    // 需要注意：在使用delegatecall时，存储布局必须一致
    // 代理合约和逻辑合约的状态变量声明顺序和类型必须相同
    uint256 public value;  // 状态变量，与代理合约保持一致
    address public owner;  // 状态变量，与代理合约保持一致

    // 事件，用于记录数值变化
    event ValueChanged(uint256 newValue);

    // 每次调用此函数时，value增加1
    function increment() external returns (uint256) {
        value += 1;
        emit ValueChanged(value);
        return value;
    }

    // 设置特定的值
    function setValue(uint256 _value) external returns (uint256) {
        value = _value;
        emit ValueChanged(value);
        return value;
    }

    // 返回当前值
    function getValue() external view returns (uint256) {
        return value;
    }
} 