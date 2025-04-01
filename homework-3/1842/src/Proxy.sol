// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Proxy {
    uint256 public counter; // 状态变量与Logic合约保持一致
    address public logicContract;

    constructor(address _logicContract) {
        logicContract = _logicContract;
    }

    // Fallback函数使用delegatecall调用逻辑合约
    fallback() external {
        (bool success, ) = logicContract.delegatecall(msg.data);
        require(success, "Delegatecall failed");
    }
}
