// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract Proxy {
    uint256 public counter;

    address public logicAddress;

    constructor(address _logicAddress) {
        require(_logicAddress != address(0), "invalid logic address");
        logicAddress = _logicAddress;
    }

    function proxyIncrement() public {

         bytes memory data = abi.encodeWithSignature("increment()");

         (bool success, ) = logicAddress.delegatecall(data);

         require(success, "Logic Increment failed");
    }
}
