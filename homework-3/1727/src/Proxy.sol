// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Logic.sol"; // Optional, but helps with interface understanding

/**
 * @title Proxy Contract
 * @dev Delegates calls to a logic contract while maintaining its own storage.
 * IMPORTANT: Storage layout must be compatible with the Logic contract.
 */
contract Proxy {
    // 存储槽 0：计数器 - 必须与逻辑合约的存储槽 0 匹配
    uint256 public count;

    // 存储槽 1（示例）：所有者 - 如果逻辑合约有，必须与逻辑合约的存储槽 1 匹配
    // address public owner;

    // 逻辑合约地址的存储槽（选择一个不太可能冲突的槽）
    // 使用 assembly 明确指定存储槽，
    // 或者正常声明（它将在声明的变量之后占用下一个可用槽）
    address public logicAddress; // 如果 owner 不存在，这通常会在存储槽 1

    // --- 或者使用特定槽来避免冲突（对升级更稳健）---
    // bytes32 private constant LOGIC_ADDRESS_SLOT =
    //     bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    // function _logicAddress() internal view returns (address impl) {
    //     bytes32 slot = LOGIC_ADDRESS_SLOT;
    //     assembly {
    //         impl := sload(slot)
    //     }
    // }
    // function _setLogicAddress(address _newLogicAddress) internal {
    //      bytes32 slot = LOGIC_ADDRESS_SLOT;
    //      assembly {
    //          sstore(slot, _newLogicAddress)
    //      }
    // }
    // --- 特定槽示例结束 ---

    event Forwarded(address indexed logic, bool success);

    /**
     * @dev 设置逻辑合约的地址
     * @param _logicAddress 已部署的逻辑合约地址
     */
    constructor(address _logicAddress) {
        require(_logicAddress != address(0), "Proxy: Invalid logic address");
        logicAddress = _logicAddress;
        // 如果使用特定槽：_setLogicAddress(_logicAddress);
    }

    /**
     * @dev 将调用委托给逻辑合约的 increment 函数
     * 执行 Logic.increment() 的代码但修改代理合约的存储
     */
    function proxyIncrement() public {
        // address target = logicAddress; // 如果使用特定槽则为 _logicAddress()
        address target = logicAddress;

        // 编码 "increment()" 的函数签名
        bytes memory data = abi.encodeWithSignature("increment()");

        // 执行 delegatecall
        (bool success, bytes memory returnData) = target.delegatecall(data);

        // 检查 delegatecall 是否成功
        require(success, "Proxy: Delegatecall failed");

        emit Forwarded(target, success);
        // 注意：除非逻辑函数返回某些内容，否则我们通常不处理 returnData
    }

    /**
    * @dev 带参数的委托调用示例
    */
    function proxySetCount(uint256 _newCount) public {
        // address target = logicAddress; // 如果使用特定槽则为 _logicAddress()
        address target = logicAddress;

        // 编码带参数的 "setCount(uint256)" 函数签名
        bytes memory data = abi.encodeWithSignature("setCount(uint256)", _newCount);

        (bool success, ) = target.delegatecall(data);
        require(success, "Proxy: Delegatecall setCount failed");
        emit Forwarded(target, success);
    }

    // --- 可选：委托任何调用的回退函数 ---
    // 这使代理更透明但需要谨慎处理
    // fallback() external payable {
    //     _delegate(logicAddress); // 或 _delegate(_logicAddress());
    // }
    // receive() external payable {
    //     _delegate(logicAddress); // 或 _delegate(_logicAddress());
    // }
    // function _delegate(address implementation) internal {
    //    assembly {
    //        calldatacopy(0, 0, calldatasize())
    //        let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
    //        returndatacopy(0, 0, returndatasize())
    //        switch result
    //        case 0 { revert(0, returndatasize()) }
    //        default { return(0, returndatasize()) }
    //    }
    //}
    // --- 回退函数结束 ---
}