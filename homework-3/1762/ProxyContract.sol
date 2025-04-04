// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyContract {
    address public logicContract;
    uint256 public count;

    constructor(address _logicContract) {
        logicContract = _logicContract;
    }

    fallback() external payable {
        (bool success, ) = logicContract.delegatecall(msg.data);
        require(success, "Delegatecall failed");
    }

    receive() external payable {}
}
