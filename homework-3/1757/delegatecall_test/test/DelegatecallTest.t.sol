// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Logic} from "../src/logic.sol";
import {Proxy} from "../src/proxy.sol";
import {Script, console} from "forge-std/Script.sol";
import {DeployedLogic} from "../script/DeployedLogic.s.sol";


contract DelegatecallTest is Test {
    Logic logic;
    Proxy proxy;
    DeployedLogic deployedLogic;
    // 合约部署这owner
    address owner = vm.addr(0x1);

    function setUp() public {
        // 部署
         //模拟执行者
        vm.prank(owner);
        deployedLogic = new DeployedLogic();
        (logic, proxy) = deployedLogic.run();
    }
    // 测试delegatecall 调用
    function testDelegatecall() public {
        // 检查初始状态
        assertEq(proxy.getX(), 0);
        assertEq(logic.getX(), 0);
        // 调用proxy的increment方法
        uint256 res = proxy.delegatecallIncrement();
        console.log("res", res);
        // 验证proxy的值是否增加
        assertEq(proxy.getX(), 1);
        // 验证logic的值是否增加 ,不应该增加
        assertEq(logic.getX(), 0);
    }

    // 测试更新代理合约
    function test_updateProxyNotOwner() public {
        // 重新部署合约
        deployedLogic = new DeployedLogic();
        (logic , proxy) = deployedLogic.run();
        // 更新代理合约
        vm.expectRevert(); // 期待下一行代码 应该回滚
        proxy.updateLogicAddress(address(logic));
    }

     function test_updateProxyOwner() public {
        vm.startPrank(proxy.getOwner());
        // 重新部署合约
        Logic newLogic  = new Logic();
        // 更新代理合约
        proxy.updateLogicAddress(address(newLogic ));
        assertEq(proxy.getLogicAddress(), address(newLogic));
        vm.stopPrank();
    }

    // 测试deleteCall调用不存在的情况
    function test_deleteCallInvalidLogic() public {
        vm.startPrank(proxy.getOwner());
        proxy.updateLogicAddress(address(new InvalidLogic()));
        // 调用不存在的方法
        vm.expectRevert(); // 期待下一行代码 应该回滚
        proxy.delegatecallIncrement();
        // 验证代理合约的值是否增加
    }
}

// 用于测试的无效逻辑合约
contract InvalidLogic {
    uint256 public counter;
    // 故意不实现 increment 函数
}