// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Proxy {
    uint256 public count;
    address public logicContract;

    constructor(address _logicContract) {
        logicContract = _logicContract;
    }

    function upgradeLogic(address _newLogic) public {
        logicContract = _newLogic;
    }

    function increment() public {
        (bool success, ) = logicContract.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Delegatecall failed");
    }
}
