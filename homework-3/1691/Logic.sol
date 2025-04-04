// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Logic{
    uint public count;

    function increase() public returns (uint){
        count = count + 1;
        return count;
    } 
}