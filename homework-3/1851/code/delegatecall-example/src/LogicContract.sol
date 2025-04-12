/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract LogicContract {
    uint256 private _counter; // 私有变量

    // 获取计数器值的公共函数
    function counter() public view returns (uint256) {
        return _counter;
    }

    // 增加计数器并返回新值
    function increment() external returns (uint256) {
        _counter = _counter + 1; // 正确操作私有变量
        return _counter;
    }
}
