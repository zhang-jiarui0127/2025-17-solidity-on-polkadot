// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Delegatecall.sol";
import "../src/Logic.sol";

contract DelegatecallTest is Test {
    // 声明合约实例
    Logic logic;
    Delegatecall delegatecall;
    
    // 测试账户
    address user = address(0x1);
    
    // 设置测试环境
    function setUp() public {
        // 部署 Logic 合约
        logic = new Logic();
        
        // 部署 Delegatecall 合约，并传入 Logic 合约地址
        delegatecall = new Delegatecall(address(logic));
        
        // 给测试用户一些 ETH
        vm.deal(user, 10 ether);
    }
    
    // 测试 proxyAdd 函数是否正确调用 Logic 合约
    function testProxyAdd() public {
        // 准备测试数据
        uint256[] memory inputs = new uint256[](3);
        inputs[0] = 10;
        inputs[1] = 20;
        inputs[2] = 30;
        
        // 切换到用户身份
        vm.startPrank(user);
        
        // 调用 proxyAdd 函数
        uint256 result = delegatecall.proxyAdd(inputs);
        
        // 验证结果是否为 1 (callCount 应该增加到 1)
        assertEq(result, 1, "Result should be 1");
        
        // 验证 delegatecall 合约的 callCount 是否为 1
        assertEq(delegatecall.callCount(), 1, "Delegatecall callCount should be 1");
        
        // 验证 Logic 合约的 callCount 是否为 0 (因为使用 delegatecall，状态变更发生在代理合约中)
        assertEq(logic.callCount(), 0, "Logic callCount should remain 0");
        
        // 再次调用 proxyAdd 函数
        result = delegatecall.proxyAdd(inputs);
        
        // 验证结果是否为 2 (callCount 应该增加到 2)
        assertEq(result, 2, "Result should be 2");
        
        // 验证 delegatecall 合约的 callCount 是否为 2
        assertEq(delegatecall.callCount(), 2, "Delegatecall callCount should be 2");
        
        // 验证 Logic 合约的 callCount 是否仍为 0
        assertEq(logic.callCount(), 0, "Logic callCount should still be 0");
        
        vm.stopPrank();
    }
    
    // 测试 getCallCount 函数
    function testGetCallCount() public {
        // 准备测试数据
        uint256[] memory inputs = new uint256[](3);
        inputs[0] = 10;
        inputs[1] = 20;
        inputs[2] = 30;
        
        // 切换到用户身份
        vm.startPrank(user);
        
        // 初始状态下 callCount 应该为 0
        assertEq(delegatecall.getCallCount(), 0, "Initial callCount should be 0");
        
        // 调用 proxyAdd 函数
        delegatecall.proxyAdd(inputs);
        
        // 调用后 callCount 应该为 1
        assertEq(delegatecall.getCallCount(), 1, "After call, callCount should be 1");
        
        vm.stopPrank();
    }
    
    // 测试传入空数组的情况
    function testProxyAddWithEmptyArray() public {
        // 准备空数组
        uint256[] memory emptyInputs = new uint256[](0);
        
        // 切换到用户身份
        vm.startPrank(user);
        
        // 调用 proxyAdd 函数，应该会失败
        vm.expectRevert();
        delegatecall.proxyAdd(emptyInputs);
        
        vm.stopPrank();
    }
    
    // 测试位与操作的正确性
    function testBitwiseAndOperation() public {
        // 准备测试数据：10 (1010) & 6 (0110) = 2 (0010)
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = 10; // 二进制: 1010
        inputs[1] = 6;  // 二进制: 0110
        
        // 切换到用户身份
        vm.startPrank(user);
        
        // 调用 proxyAdd 函数
        delegatecall.proxyAdd(inputs);
        
        // 验证 callCount 是否为 1
        assertEq(delegatecall.callCount(), 1, "callCount should be 1");
        
        vm.stopPrank();
    }
    
    // 测试 logicAddress 是否正确设置
    function testLogicAddress() public view {
        assertEq(delegatecall.logicAddress(), address(logic), "Logic address should match");
    }
    
    // 测试构造函数是否接受零地址
    function testZeroAddressRejection() public {
        // 尝试部署 Delegatecall 合约，并传入零地址
        // 如果合约没有零地址检查，这将成功；如果有检查，将会回滚
        vm.expectRevert("Logic address cannot be zero");
        new Delegatecall(address(0));
    }
}