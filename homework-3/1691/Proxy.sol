// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Proxy{
    uint public count;
    address public logic_address;

    constructor(address _logic_address){
        logic_address = _logic_address;
    }

    function proxy_increase() public{
        (bool success, ) = logic_address.delegatecall(abi.encodeWithSignature("increase()"));
        require(success, "Logic contract failed!");
    }

    fallback() external{
        address logic = logic_address;
        assembly{
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), logic, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}