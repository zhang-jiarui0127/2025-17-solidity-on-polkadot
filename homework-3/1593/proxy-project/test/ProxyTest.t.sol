// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/LogicContract.sol";
import "../src/ProxyContract.sol";

contract ProxyTest is Test {
    LogicContract public logic;
    ProxyContract public proxy;
    address public admin = address(1);
    address public user = address(2);
    address public attacker = address(999);

    function setUp() public {
        vm.prank(admin);
        logic = new LogicContract();

        vm.prank(admin);
        proxy = new ProxyContract(address(logic));

        // 为方便测试，此处不再通过逻辑合约设置 admin，
        // 而是直接由代理合约构造函数中设置 admin 为部署者
    }

    function testAdminFunctions() public {
        // 测试代理合约自身的管理函数
        vm.prank(admin);
        proxy.setLogicContract(address(0x123));
        assertEq(proxy.logicContract(), address(0x123), "Logic contract address should update");

        vm.prank(admin);
        proxy.setAdmin(user);
        assertEq(proxy.admin(), user, "Proxy admin should update");

        // 通过代理调用业务逻辑函数（delegatecall 转发至逻辑合约）
        vm.prank(user);
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Call through proxy should succeed");
    }

    function testNonAdminCannotUpgrade() public {
        vm.prank(user);
        vm.expectRevert("Only admin can call this");
        proxy.setLogicContract(address(0x123));
    }

    function testNonAdminCannotChangeAdmin() public {
        vm.prank(attacker);
        vm.expectRevert("Only admin can call this");
        proxy.setAdmin(attacker);
    }

    function testUserCanIncrement() public {
        vm.prank(user);
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Call should succeed");
        assertEq(proxy.counter(), 1, "Counter should increment");
    }

    function testStorageLayoutConsistency() public {
        // 调用业务逻辑函数通过代理转发，实际写入的是 proxy 的存储（slot0）
        vm.prank(user);
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Call failed");

        assertEq(proxy.counter(), 1, "Proxy counter should be 1");
        // 逻辑合约本身的存储未被 delegatecall 更新
        assertEq(logic.counter(), 0, "Logic counter should remain 0");

        // 使用 vm.load 从代理合约地址读取 slot0 的值
        uint slot0 = uint(vm.load(address(proxy), bytes32(uint(0))));
        assertEq(slot0, 1, "Slot 0 should be updated counter");
    }
}
