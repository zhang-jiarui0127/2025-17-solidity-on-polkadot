// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyContract {
    // 状态变量：计数器，存储在槽 0
    uint256 public counter;
    
    // 状态变量：逻辑合约的地址
    address public logicContract;
    
    // 事件：记录计数器更新
    event CounterIncremented(uint256 newValue);
    
    // 构造函数：初始化逻辑合约地址
    constructor(address _logicContract) {
        logicContract = _logicContract;
    }
    
    // 函数：通过 delegatecall 调用逻辑合约的 increment 函数
    function callIncrement() external {
        // 使用 delegatecall 调用逻辑合约的 increment 函数
        (bool success, ) = logicContract.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        
        // 确保调用成功，否则抛出错误
        require(success, "Delegatecall 失败");
        
        // 发出事件通知
        emit CounterIncremented(counter);
    }
    
    // 函数：返回当前的 counter 值
    function getCounter() external view returns (uint256) {
        return counter;
    }
    
    // 函数：更新逻辑合约地址（可选，用于升级）
    function updateLogicContract(address _newLogicContract) external {
        require(_newLogicContract != address(0), "新地址不能为零地址");
        logicContract = _newLogicContract;
    }
} 