// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyContract {
    uint public value;
    address public logicContract;
    
    constructor(address _logicContract) {
        logicContract = _logicContract;
    }
    
    receive() external payable {}
    
    function setLogicContract(address _logicContract) public {
        logicContract = _logicContract;
    }
    
    function increment() public returns (bool) {
        (bool success, ) = logicContract.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        return success;
    }
    
    function setValue(uint _newValue) public returns (bool) {
        (bool success, ) = logicContract.delegatecall(
            abi.encodeWithSignature("setValue(uint256)", _newValue)
        );
        return success;
    }
    

    fallback() external payable {
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