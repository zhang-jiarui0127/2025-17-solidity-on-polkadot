// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ProxyCounter {
    uint256 public number;

    address public logicCounterAddress;

    constructor(address _loginCounterAddress) {
        logicCounterAddress = _loginCounterAddress;
    }

    function incrementViaDelegate() external {
        (bool success,) = logicCounterAddress.delegatecall(abi.encodeWithSignature("increment()"));
        require(success, "Delegatecall failed");
    }
}
