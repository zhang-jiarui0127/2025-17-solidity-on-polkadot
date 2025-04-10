// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// 逻辑合约
contract Logic {

    // 逻辑合约的存储变量
    uint256 public logicNumber;

    // 计算逻辑：对入参数值加一
    function setNumber(uint256 _number) public {
        
        logicNumber = _number + 1;
    }

}
