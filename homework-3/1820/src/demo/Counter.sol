// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../UUPSUpgradeable.sol"; 

contract Counter is UUPSUpgradeable{

    constructor() {
        _disableInitializers();
    }

    //初始化函数 (代替构造函数) 代理合约需要控制合约的初始化过程
    function initialize(uint256 value) public onlyAdmin {
        number = value;
    }

    function increment() external {
        number += 1;
    }

    function getNumber() external view returns(uint256){
        return number;
    }
}
