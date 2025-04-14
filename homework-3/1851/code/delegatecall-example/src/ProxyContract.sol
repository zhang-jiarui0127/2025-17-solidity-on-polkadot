// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ProxyContract {
    uint256 public counter;
    address public logicContractAddress;

    constructor(address _logicContractAddress) {
        require(_logicContractAddress != address(0), "Zero address not allowed");
        logicContractAddress = _logicContractAddress;
    }

    function incrementViaDelegateCall() external returns (uint256) {
        (bool success, bytes memory data) = logicContractAddress.delegatecall(abi.encodeWithSignature("increment()"));
        require(success, "Delegatecall failed");
        counter = abi.decode(data, (uint256)); // 更新本地计数器
        return counter;
    }

    function updateLogicAddress(address newLogicAddress) external {
        require(newLogicAddress != address(0), "Zero address not allowed");
        logicContractAddress = newLogicAddress;
    }
}
