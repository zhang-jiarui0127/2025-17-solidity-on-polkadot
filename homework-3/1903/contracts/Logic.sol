// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract Logic {
    uint public count; // 存储插槽 0 
    
    function increment() external {
        count += 1;
    }
}
