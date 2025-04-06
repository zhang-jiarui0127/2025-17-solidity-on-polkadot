// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyContract {
    address public logicContract;
    uint public counter; // 存储布局必须与逻辑合约匹配
    
    constructor(address _logicContract) {
        logicContract = _logicContract;
    }
    
    // 更新逻辑合约地址
    function updateLogicContract(address _newLogicContract) external {
        logicContract = _newLogicContract;
    }
    
    // 回退函数，将所有调用转发到逻辑合约
    fallback() external payable {
        address _impl = logicContract;
        require(_impl != address(0), "Logic contract not set");
        
        assembly {
            // 复制calldata到内存
            calldatacopy(0, 0, calldatasize())
            
            // 使用delegatecall执行逻辑合约代码
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            
            // 复制返回数据到内存
            returndatacopy(0, 0, returndatasize())
            
            // 根据结果处理返回或回滚
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
    
    // 接收以太币的函数
    receive() external payable {}
}