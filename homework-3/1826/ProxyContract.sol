// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProxyContract {
    uint256 public counter; //存储插槽0(对齐逻辑)
    address public logicContract; //逻辑合约地址(插槽1)

    constructor(address _logicContract) {
        logicContract = _logicContract; //初始化逻辑合约地址
    }

    // 设置初始值
    function setCount(uint256 _count) public {
        (bool success, ) = logicContract.delegatecall(
            abi.encodeWithSignature("setCount(uint256)", _count)
        );
        require(success, "Failed to delegate call");
    }

    function increment() public {
        (bool success, ) = logicContract.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Failed to delegate call");
    }

    // 添加接收以太坊的专用函数 ✅
    receive() external payable {
        revert("ETH not accepted"); // 拒绝ETH转账
    }

    fallback() external payable {
        // 调用逻辑合约
        address logic = logicContract;
        require(logic != address(0), "Logic contract not set");
        assembly {
            // 复制 msg.data
            calldatacopy(0, 0, calldatasize())

            // 执行 delegatecall
            let result := delegatecall(gas(), logic, 0, calldatasize(), 0, 0)

            // 获取返回数据
            returndatacopy(0, 0, returndatasize())

            // 根据结果处理返回值
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
