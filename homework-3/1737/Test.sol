// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/LogicContract.sol";
import "../src/ProxyContract.sol";

contract ProxyTest is Test {
    LogicContract logic;
    ProxyContract proxy;
    
    function setUp() public {
        // 部署逻辑合约
        logic = new LogicContract();
        
        // 部署代理合约，传入逻辑合约地址
        proxy = new ProxyContract(address(logic));
    }
    
    function testIncrement() public {
        // 通过代理合约调用increment()
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Call failed");
        
        // 验证代理合约的counter被更新
        assertEq(proxy.counter(), 1);
        
        // 验证逻辑合约的counter未被更新（因为使用的是delegatecall）
        assertEq(logic.counter(), 0);
    }
    
    function testGetCounter() public {
        // 先增加两次
        (bool success1, ) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        (bool success2, ) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(success1 && success2, "Calls failed");
        
        // 通过代理合约获取counter值
        (bool success3, bytes memory data) = address(proxy).call(
            abi.encodeWithSignature("getCounter()")
        );
        require(success3, "Call failed");
        
        uint counter = abi.decode(data, (uint));
        assertEq(counter, 2);
        assertEq(proxy.counter(), 2);
    }
    
    function testUpgrade() public {
        // 第一次调用
        (bool success1, ) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(success1, "Call failed");
        
        // 部署新版本的逻辑合约
        LogicContract newLogic = new LogicContract();
        
        // 升级代理合约使用的逻辑合约
        proxy.updateLogicContract(address(newLogic));
        
        // 再次调用，应该使用新逻辑合约的代码
        (bool success2, ) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(success2, "Call failed");
        
        // 验证counter继续累加（状态保留）
        assertEq(proxy.counter(), 2);
    }
}