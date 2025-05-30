// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Storage {
    uint256 public number;
    event NumberSet(uint256 indexed oldNumber, uint256 indexed newNumber);

    function store(uint256 _number) public {
        uint256 oldNumber = number;
        number = _number;
        emit NumberSet(oldNumber, _number);
    }

    function retrieve() public view returns (uint256) {
        return number;
    }
}