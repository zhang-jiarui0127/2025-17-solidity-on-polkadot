// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Proxy {
    uint256 public counter; // 存储变量，与 Logic 合约的存储布局一致
    address public logicContract;

    constructor(address _logicContract) {
        logicContract = _logicContract;
    }

    function increment() external returns (bool success) {
        // 使用 delegatecall 调用逻辑合约的 increment 函数
        (success, ) = logicContract.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Delegatecall failed");
    }
}