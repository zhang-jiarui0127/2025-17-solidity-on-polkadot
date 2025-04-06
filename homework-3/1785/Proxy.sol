// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Proxy {
    address public logicContract;  // 逻辑合约地址
    uint256 public counter;        // 与Logic合约相同的状态变量
    
    constructor(address _logicContract) {
        logicContract = _logicContract;
    }
    
    function increment() external returns (bool success) {
        (success, ) = logicContract.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Delegatecall failed");
    }
    
    function updateLogic(address _newLogicContract) external {
        logicContract = _newLogicContract;
    }
}