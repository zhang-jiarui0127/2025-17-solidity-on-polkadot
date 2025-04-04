// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

// 创建两个合约，一个是逻辑合约，一个是代理合约。
// 逻辑合约应包含一个简单的函数，如每次调用增加 1。
// 代理合约使用 delegatecall 调用逻辑合约中的增加函数。
// 编写测试用例，验证通过代理合约调用后，状态持有者的数据被正确更新。
contract Proxy {

    // 低级调用：call
    function lowLeveCall(address _a) public returns (bytes memory){
       (bool success, bytes memory result) = _a.call(abi.encodeWithSignature("increment()"));

        // 检查调用是否成功
        require(success, "CALL failed");

        // 返回目标合约的执行结果
        return result;
    }

     // 低级调用：delegatecall
     function lowLeveDelegatecall(address _a) public returns (bytes memory){

        (bool success, bytes memory result) = _a.delegatecall(abi.encodeWithSignature("increment()"));

        // 检查调用是否成功
        require(success, "CALL failed");

        // 返回目标合约的执行结果
        return result;
    }

    // Assembly code - 访问底层存储
    function getStorage(uint index)public view returns (bytes32 value){
        assembly {
            value:=sload(index)
        }
    }
}

contract Counter {

    event log(string);

    uint256 public  i =0;

    function increment() public returns (uint256){
        i=i+1;
        emit log(unicode"Counter.increment 执行了..");
        return i;
    }

    // Assembly code - 访问底层存储
    function getStorage(uint index)public view returns (bytes32 value){
        assembly {
            value:=sload(index)
        }
    }
}