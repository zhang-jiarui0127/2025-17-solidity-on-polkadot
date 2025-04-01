// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyContract {
    uint public value;  // 必须与逻辑合约布局一致
    address public logicContract;
    
    constructor(address _logicContract) {
        logicContract = _logicContract;
    }
    
    // 修正后的fallback函数
    fallback(bytes calldata input) external payable returns (bytes memory output) {
        address impl = logicContract;
        
        // 使用delegatecall转发所有调用
        (bool success, bytes memory data) = impl.delegatecall(input);
        
        require(success, "Delegatecall failed");
        return data;
    }
    
    // 如果需要接收ETH，还需要receive函数
    receive() external payable {}
}
