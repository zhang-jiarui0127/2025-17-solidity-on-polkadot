// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LogicContract {
    // 注意：这里的 count 变量仅用于逻辑说明，在 delegatecall 调用时，其存储布局必须与代理合约保持一致
    uint256 public count;

    function increment() public {
        count += 1;
    }
}
