// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// 代理合约
contract ProxyContract {
    // 状态变量 - 这个变量会被实际修改
    uint256 public counter;
    
    // 逻辑合约的地址
    address public logicContractAddress;
    
    // 构造函数，初始化逻辑合约地址
    constructor(address _logicContractAddress) {
        require(_logicContractAddress != address(0), "Zero address not allowed");
        logicContractAddress = _logicContractAddress;
    }
    
    // 使用 delegatecall 调用逻辑合约的 increment 函数
    function incrementViaDelegateCall() external returns (uint256) {
        (bool success, bytes memory data) = logicContractAddress.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Delegatecall failed");
        
        // 解码返回数据
        return abi.decode(data, (uint256));
    }
    
    // 更新逻辑合约地址（可选）
    function updateLogicAddress(address _newLogicAddress) external {
        require(_newLogicAddress != address(0), "Zero address not allowed");
        logicContractAddress = _newLogicAddress;
    }
}
