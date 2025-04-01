// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyContract {
    uint256 public count;

    function delegateIncrement(address logicContractAddress) public {
        (bool success, ) = logicContractAddress.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Delegatecall failed");
    }
}
