// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyContract {
    // 状态变量顺序和类型必须与逻辑合约一致
    uint256 public value;  // 这个状态变量在delegatecall时会被使用
    address public owner;  // 保存合约拥有者地址
    
    // 逻辑合约地址
    address public logicContractAddress;
    
    // 事件
    event LogicCallResult(bool success, bytes returnData);
    
    // 构造函数，设置逻辑合约地址和初始owner
    constructor(address _logicContractAddress) {
        logicContractAddress = _logicContractAddress;
        owner = msg.sender;  // 设置部署者为owner
    }
    
    // 设置新的逻辑合约地址
    function setLogicContract(address _newLogicContractAddress) external {
        require(msg.sender == owner, "Only owner can change logic contract");
        logicContractAddress = _newLogicContractAddress;
    }
    
    // 使用delegatecall调用逻辑合约的函数
    function delegateCall(bytes memory _calldata) public returns (bool, bytes memory) {
        require(logicContractAddress != address(0), "Logic contract address not set");
        
        // 执行delegatecall
        (bool success, bytes memory returnData) = logicContractAddress.delegatecall(_calldata);
        
        // 触发事件
        emit LogicCallResult(success, returnData);
        
        return (success, returnData);
    }
    
    // 方便用户调用increment函数
    function increment() external returns (uint256) {
        // 构造调用increment()函数的calldata
        bytes memory callData = abi.encodeWithSignature("increment()");
        
        // 执行delegatecall
        (bool success, bytes memory returnData) = delegateCall(callData);
        
        // 检查调用是否成功
        require(success, "Delegate call failed");
        
        // 解码返回值
        return abi.decode(returnData, (uint256));
    }
    
    // 方便用户调用setValue函数
    function setValue(uint256 _value) external returns (uint256) {
        // 构造调用setValue(uint256)函数的calldata
        bytes memory callData = abi.encodeWithSignature("setValue(uint256)", _value);
        
        // 执行delegatecall
        (bool success, bytes memory returnData) = delegateCall(callData);
        
        // 检查调用是否成功
        require(success, "Delegate call failed");
        
        // 解码返回值
        return abi.decode(returnData, (uint256));
    }
    
    // 方便用户调用getValue函数
    function getValue() external view returns (uint256) {
        return value; // 直接返回本合约存储的值
    }
} 