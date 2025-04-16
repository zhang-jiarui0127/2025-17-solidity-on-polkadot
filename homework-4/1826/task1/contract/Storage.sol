// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Storage {
    uint256 public number;
    event NumChanged(uint256 newNumber);
    event oldNum(uint256 oldNumber);

    function setNumber(uint256 newNum) public {
        emit oldNum(number);
        number = newNum;
        emit NumChanged(newNum);
    }

    function getNumber() public view returns (uint256) {
        return number;
    }
}
