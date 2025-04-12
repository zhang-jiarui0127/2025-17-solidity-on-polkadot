// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Storage {
    uint256 number;
    
    // 存储事件
    event NumberStored(address indexed sender, uint256 value);

    function store(uint256 num) public {
        number = num;
        emit NumberStored(msg.sender, num); // 触发事件
    }

    function retrieve() public view returns (uint256) {
        return number;
    }
}