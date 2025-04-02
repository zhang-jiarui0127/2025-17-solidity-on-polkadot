// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Proxy {
    uint256 public value;
    address public sender;
    uint256 public timestamp;
    address public logicContract;

    constructor(address _logicContract) {
        logicContract = _logicContract;
    }

    fallback() external payable {
        address _impl = logicContract;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
    
    function setValue(uint256 _value) external {
        bytes memory data = abi.encodeWithSignature("setValue(uint256)", _value);
        (bool success, ) = logicContract.delegatecall(data);
        require(success, "Delegatecall failed");
    }
}