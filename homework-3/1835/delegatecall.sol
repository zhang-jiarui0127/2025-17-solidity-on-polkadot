// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 逻辑合约，包含实际的业务逻辑
contract LogicContract {
    // 状态变量，用于存储计数
    uint256 public counter;
    address public lastCaller;
    
    // 每次调用增加计数器的函数
    function increment() external {
        counter += 1;
        lastCaller = msg.sender;
    }
    
    // 获取当前计数的函数
    function getCounter() external view returns (uint256) {
        return counter;
    }
}

// 代理合约，负责将调用转发到逻辑合约
contract ProxyContract {
    // 状态变量，必须与逻辑合约的状态变量结构完全一致！
    uint256 public counter;
    address public lastCaller;
    
    // 逻辑合约的地址
    address public logicContractAddress;
    
    // 构造函数，设置逻辑合约地址
    constructor(address _logicContractAddress) {
        logicContractAddress = _logicContractAddress;
    }
    
    // 更新逻辑合约地址的函数（用于升级）
    function setLogicContract(address _newLogicContractAddress) external {
        logicContractAddress = _newLogicContractAddress;
    }
    
    // 代理函数，使用delegatecall调用逻辑合约的increment函数
    function increment() external {
        // 使用delegatecall调用逻辑合约的函数
        (bool success, ) = logicContractAddress.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        
        require(success, "Delegatecall failed");
    }
    
    // 获取当前计数的函数
    function getCounter() external view returns (uint256) {
        return counter;
    }
}
