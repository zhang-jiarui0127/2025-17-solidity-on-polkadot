// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILogic {
    function add(uint256[] calldata inputs) external returns (uint256);
}

contract Delegatecall {
    // 存储布局必须与 Logic 合约相同
    uint256 public callCount;
    
    // Logic 合约地址
    address public logicAddress;
    
    // 构造函数设置 Logic 合约地址
    constructor(address _logicAddress) {
        require(_logicAddress != address(0), "Logic address cannot be zero");
        logicAddress = _logicAddress;
    }
    
    // 通过 delegatecall 调用 Logic 合约的 add 函数
    function proxyAdd(uint256[] calldata inputs) external returns (uint256) {
        // 使用 delegatecall 调用 Logic 合约
        (bool success, bytes memory data) = logicAddress.delegatecall(
            abi.encodeWithSignature("add(uint256[])", inputs)
        );
        
        // 检查调用是否成功
        require(success, string(abi.encodePacked("Delegatecall failed: ", data)));
        
        // 解码返回值
        return abi.decode(data, (uint256));
    }
    
    // 获取当前计数器值
    function getCallCount() external view returns (uint256) {
        return callCount;
    }
}