// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LogicContractProxy {
    address implementContract;

    constructor(address _implementContract) {
        implementContract = _implementContract;
    }

    function increment() public {
        (bool success, ) = implementContract.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Failed to delegate call");
    }

    receive() external payable {
        _delegate(implementContract);
    }

    fallback() external payable {
        _delegate(implementContract);
    }

    function _delegate(address _implementation) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(
                gas(),
                _implementation,
                0,
                calldatasize(),
                0,
                0
            )
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
