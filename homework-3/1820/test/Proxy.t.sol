// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import "../src/demo/Counter.sol";
import "../src/demo/CounterProxy.sol";

contract ProxyTest is Test{
    Proxy public proxy;
    Counter public counter1;
    Counter public counter2;

    address admin = address(0x123);
    address user = address(0x456);

    function setUp() public {
        counter1 = new Counter(); 
        counter2 = new Counter();       
        address counterAddr = address(counter1);
        proxy = new Proxy(counterAddr, admin);

        //初始化存储（通过代理调用）
        vm.prank(admin);  //模拟 msg.sender 为 admin      
        (bool success,) = address(proxy).call(
            abi.encodeWithSignature("initialize(uint256)", 1)
        );
        require(success, "Init failed");

    }

    function test_Initialization() public {
        //验证实现地址
        (, bytes memory implData) = address(proxy).staticcall(
            abi.encodeWithSignature("getImplementation()")
        );
        assertEq(address(counter1), abi.decode(implData, (address)));

        //验证计数器
        (, bytes memory counterData) = address(proxy).staticcall(
            abi.encodeWithSignature("getNumber()")
        );
        assertEq(1, abi.decode(counterData, (uint256)));
    }

    function test_Increment() public {
        (bool success,) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(success, 'increment call failed');

        //验证结果
        (, bytes memory data) = address(proxy).staticcall(
            abi.encodeWithSignature("getNumber()")
        );
        assertEq(2, abi.decode(data, (uint256)));
    }

    //测试合约升级权限控制
    function test_UpgradePermission() public {
        //切换用户身份
        vm.prank(user);
        vm.expectRevert("Unauthorized");
        (bool success,) = address(proxy).call(
            abi.encodeWithSignature("upgradeTo(address)", address(counter2))
        );
    }

    //测试合约升级
    function test_Upgrade() public {
        
        //更新状态
        (bool b1,) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(b1, 'increment call failed');
        
        (, bytes memory n1) = address(proxy).staticcall(
            abi.encodeWithSignature("getNumber()")
        );
        assertEq(2, abi.decode(n1, (uint256)));

        //管理员执行升级
        vm.prank(admin);
        //升级
        (bool b2,) = address(proxy).call(
            abi.encodeWithSignature("upgradeTo(address)", address(counter2))
        );
        require(b2, "Upgrade failed");
        //验证升级
        (, bytes memory implNew) = address(proxy).staticcall(
            abi.encodeWithSignature("getImplementation()")
        );
        assertEq(address(counter2), abi.decode(implNew, (address)));

        //验证状态保留
        (, bytes memory n2) = address(proxy).staticcall(
            abi.encodeWithSignature("getNumber()")
        );
        assertEq(2, abi.decode(n2, (uint256)));

        //测试新逻辑功能
        (bool b3,) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(b3, "Call failed");
        
        (, bytes memory n3) = address(proxy).staticcall(
            abi.encodeWithSignature("getNumber()")
        );
        assertEq(3, abi.decode(n3, (uint256)));
    }
}