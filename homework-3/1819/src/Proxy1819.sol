// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Proxy1819 {
    // 存储逻辑合约地址
    address public implementation;

    // 状态变量，存储在代理合约中
    uint256 public counter;

    // 构造函数，初始化逻辑合约地址
    constructor(address _implementation) {
        implementation = _implementation;
    }

    // 更新逻辑合约地址（可选）
    function upgrade(address _newImplementation) external {
        implementation = _newImplementation;
    }

    // 回退函数，使用delegatecall调用逻辑合约
    fallback() external payable {
        address impl = implementation;
        require(impl != address(0), "Implementation not set");

        // 使用delegatecall调用逻辑合约
        (bool success, ) = impl.delegatecall(msg.data);
        require(success, "Delegatecall failed");
    }

    // 接收ETH（可选）
    receive() external payable {}
}