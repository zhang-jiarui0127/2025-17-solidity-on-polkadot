// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Logic} from "../src/Logic.sol";
import {Proxy} from "../src/Proxy.sol";

contract DelegatecallTest is Test {
    Logic public logicContract;
    Proxy public proxyContract;
    address public user = address(0x123); // 示例用户地址

    function setUp() public {
        // 1. 部署逻辑合约
        logicContract = new Logic();
        console.log("Logic contract deployed at:", address(logicContract));

        // 2. 部署代理合约，指向逻辑合约
        proxyContract = new Proxy(address(logicContract));
        console.log("Proxy contract deployed at:", address(proxyContract));
        console.log("Proxy pointing to logic:", proxyContract.logicAddress());
    }

    /**
     * @dev 测试通过 delegatecall 调用 proxyIncrement 更新代理合约的状态，
     *      但不更新逻辑合约的状态
     */
    function testDelegatecallUpdatesProxyState() public {
        // --- 初始状态验证 ---
        uint256 initialProxyCount = proxyContract.count();
        uint256 initialLogicCount = logicContract.count();

        console.log("Initial Proxy count:", initialProxyCount);
        console.log("Initial Logic count:", initialLogicCount);

        assertEq(initialProxyCount, 0, "Initial proxy count should be 0");
        assertEq(initialLogicCount, 0, "Initial logic count should be 0");

        // --- 执行操作 ---
        // 模拟 'user' 调用代理合约的 proxyIncrement 函数
        // vm.prank(user); // 这里不是必需的，因为状态更改不依赖于权限
        proxyContract.proxyIncrement();
        console.log("Called proxyIncrement() on Proxy contract");

        // --- 最终状态验证 ---
        uint256 finalProxyCount = proxyContract.count();
        uint256 finalLogicCount = logicContract.count();

        console.log("Final Proxy count:", finalProxyCount);
        console.log("Final Logic count:", finalLogicCount); // Should remain unchanged

        // 断言：代理合约的计数应该增加 1
        assertEq(finalProxyCount, initialProxyCount + 1, "Proxy count should have incremented"); // 期望为 1

        // 断言：逻辑合约的计数应该保持不变（因为 delegatecall 在代理合约的上下文中运行）
        assertEq(finalLogicCount, initialLogicCount, "Logic count should NOT have changed"); // 期望为 0
    }

     /**
     * @dev 测试通过 delegatecall 调用 proxySetCount 更新代理合约的状态
     */
    function testDelegatecallSetCountUpdatesProxyState() public {
       uint256 targetCount = 99;

        // --- 初始状态验证 ---
        assertEq(proxyContract.count(), 0, "Initial proxy count should be 0");
        assertEq(logicContract.count(), 0, "Initial logic count should be 0");

        // --- 执行操作 ---
        proxyContract.proxySetCount(targetCount);
        console.log("Called proxySetCount(%s) on Proxy contract", targetCount);

        // --- 最终状态验证 ---
        assertEq(proxyContract.count(), targetCount, "Proxy count should be set to targetCount");
        assertEq(logicContract.count(), 0, "Logic count should still be 0");
    }

    /**
     * @dev 测试直接调用逻辑合约会增加其自身状态
     * 这确认了逻辑合约可以独立工作
     */
    function testDirectCallToLogicUpdatesLogicState() public {
         // --- 初始状态验证 ---
        assertEq(proxyContract.count(), 0, "Initial proxy count should be 0");
        assertEq(logicContract.count(), 0, "Initial logic count should be 0");

        // --- 执行操作 ---
        logicContract.increment();
        console.log("Called increment() directly on Logic contract");

        // --- 最终状态验证 ---
         assertEq(proxyContract.count(), 0, "Proxy count should remain 0 after direct logic call");
         assertEq(logicContract.count(), 1, "Logic count should be 1 after direct call");
    }
}