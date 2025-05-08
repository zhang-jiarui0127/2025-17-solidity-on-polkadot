// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

// 逻辑合约，包含计数器逻辑
contract LogicContract {
    uint256 public counter;

    // 增加计数值的函数
    function increment() external {
        counter += 1;
    }
}

// 代理合约
contract ProxyContract {
    // 保持与逻辑合约相同的存储布局
    uint256 public counter;

    address public logicContract;

    constructor(address _logicContract) {
        logicContract = _logicContract;
    }

    function callIncrement() external {
        (bool success, ) = logicContract.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Delegatecall failed");
    }
}