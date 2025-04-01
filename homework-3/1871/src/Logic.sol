// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract Logic {
  uint256 public counter;

  constructor() {}

  function increment() public {
    counter++;
  }
}
