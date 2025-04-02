// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyContract {
    uint public counter;  // 必须与逻辑合约有相同的存储布局 ***** （代理合约和逻辑合约的存储变量 声明顺序必须完全一致，否则 delegatecall 会导致存储冲突）
    address public logicContract;
    
    constructor(address _logicContract) {
        logicContract = _logicContract;
    }
    
    function setLogicContract(address _logicContract) public {
        logicContract = _logicContract;
    }
    
    fallback() external payable {
        address _impl = logicContract;
        require(_impl != address(0), "Logic contract not set");
        
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
    
    receive() external payable {}
}