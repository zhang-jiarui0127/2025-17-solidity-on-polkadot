// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Proxy {
    address public logicContractAddress;
    uint256 public counter; // State is stored here

    constructor(address _logicContractAddress) {
        logicContractAddress = _logicContractAddress;
    }

    function incrementProxy() public returns (bool success) {
        // Get the function selector for Logic.increment()
        bytes4 selector = bytes4(keccak256("increment()"));

        // Use delegatecall to execute Logic.increment() in the context of Proxy
        (success, ) = logicContractAddress.delegatecall(abi.encodeWithSelector(selector));
        require(success, "Delegatecall failed");
    }

    // Optional: Function to update the logic contract address
    function setLogicContractAddress(address _newLogicContractAddress) public {
        logicContractAddress = _newLogicContractAddress;
    }
} 