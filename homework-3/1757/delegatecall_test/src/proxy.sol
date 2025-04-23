// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import "./logic.sol";

// 代理合约
contract Proxy {
    
    // x
    uint256 public s_x;

    // 被代理合约的地址
    address public s_logicAddress;

    // 合约部署者
    address public owner;

    

    // 权限控制
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    // 构造函数
    constructor(address _logicContractAddress) {
        s_logicAddress = _logicContractAddress;
        // 赋值owner
        owner = msg.sender;
    }
    // 代理函数
    function delegatecallIncrement() public returns (uint256) {
        (bool success, bytes memory data) = s_logicAddress.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        // 如果delegatecall失败，则revert
        require(success, "Delegatecall failed");
        // 如果delegatecall成功，则返回结果
        return abi.decode(data, (uint256));
    }

    // 更新代理合约的地址 ，只能合约部署者能够修改
    function updateLogicAddress(address _logicContractAddress) public onlyOwner {
        s_logicAddress = _logicContractAddress;
    }
    // 设置x
    function setX(uint256 _x) public onlyOwner {
        s_x = _x;
    }
    // 获取x
    function getX() public view returns (uint256) {
        return s_x;
    }
    // 获取代理合约的地址
    function getLogicAddress() public view returns (address) {
        return s_logicAddress;
    }
    // 获取合约部署者
    function getOwner() public view returns (address) {
        return owner;
    }
}


