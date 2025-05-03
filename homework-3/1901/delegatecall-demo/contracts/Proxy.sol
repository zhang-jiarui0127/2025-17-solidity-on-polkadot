// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Proxy {
    uint256 public counter;
    address public logic;

    constructor(address _logic) {
        logic = _logic;
    }

    function delegateIncrement() public {
        (bool success, ) = logic.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Delegatecall failed");
    }
}