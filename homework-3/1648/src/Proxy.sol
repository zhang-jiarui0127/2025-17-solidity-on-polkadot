// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Proxy {
    uint256 public count;
    address public implementation; // 逻辑合约地址

    // 代理合约构造函数
    constructor(address _implementation) {
        implementation = _implementation;
    }

    // 设置初始值
    function setCount(uint256 _count) public {
        (bool success,) = implementation.delegatecall(abi.encodeWithSignature("setCount(uint256)", _count));
        require(success, "Failed to delegate call");
    }

    function increment() public {
        (bool success,) = implementation.delegatecall(abi.encodeWithSignature("increment()"));
        require(success, "Failed to delegate call");
    }

    receive() external payable {}

    // Fallback 函数用于转发调用到逻辑合约
    fallback() external payable {
        _delegate(implementation);
    }

    // 内部委托调用函数
    function _delegate(address _implementation) internal {
        assembly {
            // 复制 msg.data
            calldatacopy(0, 0, calldatasize())

            // 执行 delegatecall
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            // 获取返回数据
            returndatacopy(0, 0, returndatasize())

            // 根据结果处理返回值
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
