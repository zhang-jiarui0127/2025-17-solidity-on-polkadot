// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/LogicContract.sol";
import "../contracts/ProxyContract.sol";

contract ProxyTest is Test {
    LogicContract public logic;
    ProxyContract public proxy;
    
    function setUp() public {
        logic = new LogicContract();
        proxy = new ProxyContract(address(logic));
    }
    
    function testIncrement() public {
        // 通过代理合约调用increment()
        (bool success, bytes memory data) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Call failed");
        
        // 验证代理合约的counter被更新
        assertEq(proxy.counter(), 1);
        
        // 验证逻辑合约的counter未被更新
        assertEq(logic.counter(), 0);
    }
    
    function testLogicUpgrade() public {
        // 第一次调用
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Call failed");
        
        // 创建新版本的逻辑合约
        LogicContract newLogic = new LogicContract();
        
        // 升级逻辑合约
        proxy.updateLogicContract(address(newLogic));
        
        // 第二次调用
        (success, ) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Call failed");
        
        // 验证counter继续增加
        assertEq(proxy.counter(), 2);
    }
}