// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LogicContract {
    uint public counter;
    
    function increment() public returns (uint) {
        counter += 1;
        return counter;
    }
}