// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Proxy {
    uint256 public count; // 存储槽位 0（必须与 Logic 合约一致）

    function delegateCallIncrement(address _logic) public {
        (bool success, ) = _logic.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Delegatecall failed");
    }
}