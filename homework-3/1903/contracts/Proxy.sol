// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract Proxy {
    uint public count;   // 存储插槽 0 (必须与 Logic 合约一致)
    address public logic; // 存储插槽 1
    constructor(address _logic) {
        logic = _logic;
    }
    bytes4 private constant INCREMENT_SELECTOR = bytes4(keccak256("increment()"));
    // 通过安全的选择器编码执行委托调用
    function delegatedIncrement() external {
        (bool success, ) = logic.delegatecall(
        abi.encodePacked(INCREMENT_SELECTOR)
         );
        require(success, "Delegatecall failed");
    }
}