// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LogicContract {

    uint public value;
    
    function increment() public {
        value += 1;
    }
    
    function setValue(uint _newValue) public {
        value = _newValue;
    }
}