// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Proxy {
    // 确保参数布局一致，以便后续的ABI编码和解码正确执行
    uint256 public counter;
    address public logicAddress;

    constructor(address _logicAddress) {
        require(_logicAddress != address(0), "Invalid logic address");
        logicAddress = _logicAddress;
    }

    // 通过delegatecall调用逻辑合约的increment函数
    function incrementDelegatecall() external returns (uint256) {
        (bool success, bytes memory returndata) = logicAddress.delegatecall(abi.encodeWithSignature("increment()"));
        require(success, "Delegatecall failed");
        return abi.decode(returndata, (uint256));
    }

    // 更新逻辑合约地址
    function updateLogicAddress(address _newLogicAddress) external {
        require(_newLogicAddress != address(0), "Invalid new logic address");
        logicAddress = _newLogicAddress;
    }
}
