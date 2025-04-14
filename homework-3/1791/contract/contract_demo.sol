// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


// 实现一个简单的 Solidity 合约，展示如何使用 delegatecall 来执行一个逻辑合约的函数，同时确保调用者的状态被保留。
/*
创建两个合约，一个是逻辑合约，一个是代理合约。

逻辑合约应包含一个简单的函数，如每次调用增加 1。

代理合约使用 delegatecall 调用逻辑合约中的增加函数。

编写测试用例，验证通过代理合约调用后，状态持有者的数据被正确更新。
*/

contract Proxy {
    uint256 public count; // slot0
    address public logicContract;

    constructor(address _logicContract) {
        logicContract = _logicContract;
    }

    fallback() external payable {
        address impl = logicContract;

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}

    function getStorage(uint solt) public view returns(bytes32 data) {
        assembly {
            data := sload(solt)
        }
    }
}

contract Logic {
    uint256 public count;

    function incr() public{
        count += 1;
    }
}