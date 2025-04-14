// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Proxy {
    address public logicContractAddress;
    uint256 public counter;

    constructor(address _logicContractAddress) {
        logicContractAddress = _logicContractAddress;
    }

    function incrementProxy() public returns (bool success) {
        bytes4 selector = bytes4(keccak256("increment()"));

        (success, ) = logicContractAddress.delegatecall(abi.encodeWithSelector(selector));
        require(success, "Delegatecall failed");
    }

    function setLogicContractAddress(address _newLogicContractAddress) public {
        logicContractAddress = _newLogicContractAddress;
    }
} 