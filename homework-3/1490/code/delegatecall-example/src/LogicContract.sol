// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract LogicContract {
    uint256 public counter;

    function increment() external returns (uint256) {
        counter = counter + 1;
        return counter;
    }
}
