// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyContract {
    // 存储逻辑合约地址
    address public logicContract;
    // 与 LogicContract 中 count 的存储槽一致
    uint256 public count;

    constructor(address _logicContract) {
        logicContract = _logicContract;
    }

    // fallback 函数，转发所有调用到逻辑合约
    fallback() external payable {
        (bool success, ) = logicContract.delegatecall(msg.data);
        require(success, "Delegatecall failed");
    }

    // 可选：接收 ETH
    receive() external payable {}
}
