// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Storage {
    uint256 private number;

    event NumberChanged(uint256 newNumber);

    function set(uint256 num) public {
        number = num;
        emit NumberChanged(num);
    }

    function get() public view returns (uint256) {
        return number;
    }
}
