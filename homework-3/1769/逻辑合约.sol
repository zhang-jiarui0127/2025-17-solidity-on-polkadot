// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.0;  

contract Incrementer {  
    uint256 public ap; 

    function increment() public {  
        ap += 1;  
    }  
}  