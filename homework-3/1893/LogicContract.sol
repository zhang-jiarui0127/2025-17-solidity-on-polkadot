// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LogicContract {
    // 存储插槽0
    uint256 public counter;

    function increment() public {
        counter++;
    }
}
