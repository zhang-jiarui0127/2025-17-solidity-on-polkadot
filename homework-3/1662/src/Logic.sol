// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Logic {
    // 添加计数器状态变量
    uint256 public callCount;
    
    function add(uint256[] calldata inputs) external returns (uint256 result) {
        require(inputs.length > 0, "Input array must not be empty");
        
        // 先将结果初始化为第一个元素
        result = inputs[0];
        
        // 然后对剩余元素进行位与操作
        for (uint256 i = 1; i < inputs.length; ) {
            result &= inputs[i];
            unchecked { i++; }
        }
        
        // 每次调用后增加计数器
        unchecked { callCount++; }
        
        return callCount;
    }
}