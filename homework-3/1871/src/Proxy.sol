// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract Proxy {
  uint256 public counter;

  event DelegatecallIncrement(address target, uint256 counter, bytes data);

  error Proxy__DelegatecallFailed(address target, bytes data);

  constructor() {}

  function delegatecallIncrement(address logicAddr) public {
    bytes memory functionBytes = abi.encodeWithSignature("increment()");
    (bool success, bytes memory result) = logicAddr.delegatecall(functionBytes);
    if (!success) {
      revert Proxy__DelegatecallFailed(logicAddr, functionBytes);
    }

    emit DelegatecallIncrement(logicAddr, counter, result);
  }
}
