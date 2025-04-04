// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Logic {
    uint256 public value;
    address public sender;
    uint256 public timestamp;

    event ValueChanged(address indexed _sender, uint256 _value, uint256 _timestamp);

    function setValue(uint256 _value) public {
        value = _value;
        sender = msg.sender;
        timestamp = block.timestamp;
        
        emit ValueChanged(msg.sender, _value, block.timestamp);
    }
}