// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyContract {
    address public logicContract;
    uint public counter;
    
    constructor(address _logicContract) {
        logicContract = _logicContract;
    }
    
    function updateLogicContract(address _newLogicContract) public {
        logicContract = _newLogicContract;
    }
    
    fallback() external {
        address _impl = logicContract;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}