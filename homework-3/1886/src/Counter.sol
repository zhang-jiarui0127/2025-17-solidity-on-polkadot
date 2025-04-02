// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Logic {
    uint256 public count; // store in Slot 0

    function increase() public {
        count++;
    }
}

contract Proxy {
    function callLogic(address _to, bool is_delegatecall) public {
        bytes memory data = abi.encode(Logic.increase.selector);

        // Call the logic contract
        if (is_delegatecall) {
            assembly {
                pop(
                    delegatecall(gas(), _to, add(data, 0x20), mload(data), 0, 0)
                )
            }
        } else {
            assembly {
                pop(call(gas(), _to, 0, add(data, 0x20), mload(data), 0, 0))
            }
        }
    }

    function getStorage(uint _slot) public view returns (bytes32 result) {
        assembly {
            result := sload(_slot)
        }
    }
}
