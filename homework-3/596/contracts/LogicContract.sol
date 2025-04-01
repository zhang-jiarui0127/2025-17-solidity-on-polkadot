// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LogicContract {
    // 注意：这个变量实际上不会被使用
    // 因为存储布局必须与代理合约匹配
    uint public value;
    
    /**
     * @dev 增加数值的函数
     * 注意：这个函数会修改代理合约的存储
     */
    function increment() public {
        // 这个操作会修改代理合约中的value变量
        value += 1;
    }
    
    /**
     * @dev 获取当前值
     */
    function getValue() public view returns (uint) {
        return value;
    }
}
