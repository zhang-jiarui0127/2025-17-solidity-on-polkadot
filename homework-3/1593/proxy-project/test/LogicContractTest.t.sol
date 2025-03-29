// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/LogicContract.sol";

contract LogicContractTest is Test {
    LogicContract public logic;
    address public admin = address(1);
    address public user = address(2);

    function setUp() public {
        // 模拟管理员部署合约
        vm.prank(admin);
        logic = new LogicContract();
    }

    function testInitialAdmin() public {
        // 测试构造函数中设置的 admin 是否为部署者
        assertEq(logic.admin(), admin, "Admin should be the deployer");
    }

    function testIncrement() public {
        // 调用 increment() 函数，测试 counter 累加是否正确
        uint result = logic.increment();
        assertEq(result, 1, "Counter should be 1 after first increment");
        
        result = logic.increment();
        assertEq(result, 2, "Counter should be 2 after second increment");
        
        // 直接读取 counter 变量
        assertEq(logic.counter(), 2, "Counter should be 2");
    }
}
