// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ProxyContract {
    // 状态变量 - 必须与逻辑合约完全匹配
    uint256 public dataValue;
    address public owner;

    // 逻辑合约地址
    address public implementation;

    event IncrementEvent(address indexed sender, bool success, bytes data);

    // 构造函数设置逻辑合约地址
    constructor(address _implementation) {
        implementation = _implementation;
    }

    // 初始化函数
    function initialize() public {
        // 确保只能初始化一次
        require(owner == address(0), "Already initialized");

        // 使用delegatecall调用逻辑合约的初始化函数
        (bool success, ) = implementation.delegatecall(
            abi.encodeWithSignature("initialize()")
        );
        require(success, "Initialization failed");
    }

    // 通过delegatecall调用逻辑合约的increment函数
    function increment() public returns (uint256) {
        (bool success, bytes memory data) = implementation.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        emit IncrementEvent(msg.sender, success, data);

        require(success, "Increment failed");
        return abi.decode(data, (uint256));
    }

    // 回退函数，允许调用逻辑合约的任何函数
    fallback() external payable {
        address _impl = implementation;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    // 接收以太币的函数
    receive() external payable {}
}
