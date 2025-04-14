// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// 代理合约
contract Proxy {

    // 代理合约中的存储变量
    uint256 public proxyNumber;

    // 使用delegatecall调用业务合约
    function delegateSetNumber(address _logic, uint256 _number) public {
        
        // 执行delegatecall调用业务合约，使用选择器确定调用代理合约的具体方法，并传入参数_number做数值计算。
        (bool success, ) = _logic.delegatecall(
            abi.encodeWithSignature("setNumber(uint256)", _number)
        );

        // 确定delegatecall调用是否成功
        require(success, "Deledatecall failed");

    }
 
}
