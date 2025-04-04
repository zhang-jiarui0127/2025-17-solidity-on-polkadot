// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 代理合约
contract ProxyContract {
    uint256 public count;

    function delegateIncrement(address logicContract) public {
        (bool success, ) = logicContract.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Delegatecall failed");
    }
}