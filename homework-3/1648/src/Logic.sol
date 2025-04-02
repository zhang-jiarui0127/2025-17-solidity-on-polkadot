// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Logic {
    uint256 public count;

    function setCount(uint256 _count) public {
        count = _count;
    }

    function getCount() public view returns (uint256) {
        return count;
    }

    function increment() public {
        count += 1;
    }
}
