// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MathLogicProxy {
    // 状态变量必须与逻辑合约保持一致的顺序
    uint256 public result;
    address public owner;
    uint256 public count = 100;
    
    // 逻辑合约地址
    address public logicContract;
    
    constructor(address _logicContract) {
        logicContract = _logicContract;
        owner = msg.sender;
    }
    
    // 修改逻辑合约地址的函数
    function updateLogicContract(address _newLogic) external {
        require(msg.sender == owner, "Only owner can update logic");
        logicContract = _newLogic;
    }
    
    // 代理调用add函数
    function add(uint256 x, uint256 y, bool useProxy) external {
        if (useProxy) {
            // 使用代理合约（delegatecall）
            (bool success, ) = logicContract.delegatecall(
                abi.encodeWithSignature("add(uint256,uint256)", x, y)
            );
            require(success, "Delegatecall failed");
        } else {
            // 直接调用逻辑合约
            (bool success, ) = logicContract.call(
                abi.encodeWithSignature("add(uint256,uint256)", x, y)
            );
            require(success, "Call failed");
        }
    }
    
    // 代理调用subtract函数
    function subtract(uint256 x, uint256 y, bool useProxy) external {
        if (useProxy) {
            (bool success, ) = logicContract.delegatecall(
                abi.encodeWithSignature("subtract(uint256,uint256)", x, y)
            );
            require(success, "Delegatecall failed");
        } else {
            (bool success, ) = logicContract.call(
                abi.encodeWithSignature("subtract(uint256,uint256)", x, y)
            );
            require(success, "Call failed");
        }
    }
    
    // 代理调用multiply函数
    function multiply(uint256 x, uint256 y, bool useProxy) external {
        if (useProxy) {
            (bool success, ) = logicContract.delegatecall(
                abi.encodeWithSignature("multiply(uint256,uint256)", x, y)
            );
            require(success, "Delegatecall failed");
        } else {
            (bool success, ) = logicContract.call(
                abi.encodeWithSignature("multiply(uint256,uint256)", x, y)
            );
            require(success, "Call failed");
        }
    }
    
    // 代理调用divide函数
    function divide(uint256 x, uint256 y, bool useProxy) external {
        if (useProxy) {
            (bool success, ) = logicContract.delegatecall(
                abi.encodeWithSignature("divide(uint256,uint256)", x, y)
            );
            require(success, "Delegatecall failed");
        } else {
            (bool success, ) = logicContract.call(
                abi.encodeWithSignature("divide(uint256,uint256)", x, y)
            );
            require(success, "Call failed");
        }
    }
    
    // 获取结果，增加useProxy参数来区分获取哪个合约的result
    function getResult(bool useProxy) external view returns (uint256) {
        if (useProxy) {
            // 获取代理合约的result
            return result;
        } else {
            // 获取逻辑合约的result
            (bool success, bytes memory data) = logicContract.staticcall(
                abi.encodeWithSignature("getResult()")
            );
            require(success, "Static call failed");
            return abi.decode(data, (uint256));
        }
    }
}
