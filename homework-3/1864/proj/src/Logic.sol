// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Logic {
    uint256 public count; // 存储槽位 0

    function increment() public {
        count += 1;
    }
}