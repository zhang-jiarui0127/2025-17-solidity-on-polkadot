// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 1️⃣ **逻辑合约**
contract Logic {
    uint256 public count;

    function increment() public {
        count += 1;
    }
}
