// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 代理合约：通过 delegatecall 执行逻辑
contract Proxy {
    uint public count;          // 必须与逻辑合约的存储布局相同（位置0）
    address public logicContract; // 位置1

    constructor(address _logic) {
        logicContract = _logic;
    }

    // 通过 delegatecall 调用逻辑合约的 increment 函数
    function executeIncrement() public {
        (bool success, ) = logicContract.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Delegatecall failed");
    }
}