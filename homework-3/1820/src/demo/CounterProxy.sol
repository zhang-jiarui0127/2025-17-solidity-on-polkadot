// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../Storage.sol";

contract Proxy is Storage{
    constructor(address implementation, address admin) {
        //初始化存储
        assembly{
            sstore(_IMPLEMENTATION_SLOT, implementation)
            sstore(_ADMIN_SLOT, admin)
        }
    }

    fallback() external payable {
        address impl = getImplementation();
        assembly{
            calldatacopy(0, 0, calldatasize())
            
            let result := delegatecall(
                gas(),
                impl,
                0,
                calldatasize(),
                0,
                0
            )
            
            returndatacopy(0, 0, returndatasize())
            
            switch result
                case 0 { revert(0, returndatasize()) }
                default { return(0, returndatasize()) }
        }
    }
}