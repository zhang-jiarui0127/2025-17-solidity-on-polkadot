// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MathLogic {
    // 状态变量
    uint256 public result;
    address public owner;
    uint256 public count = 1000;
    
    // 数学运算函数
    function add(uint256 x, uint256 y) external {
        result = x + y + count;
    }
    
    function subtract(uint256 x, uint256 y) external {
        require(result >= x, "Result would be negative");
        result =  x - y+count;
    }
    
    function multiply(uint256 x, uint256 y) external {
        result = x * y + count;
    }
    
    function divide(uint256 x, uint256 y) external {
        require(x > 0 && y > 0, "Cannot divide by zero");
        result = x / y + count;
    }
    
    function getResult() external view returns (uint256) {
        return result;
    }
}
