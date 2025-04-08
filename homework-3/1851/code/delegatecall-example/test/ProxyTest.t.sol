// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {LogicContract} from "../src/LogicContract.sol";
import {ProxyContract} from "../src/ProxyContract.sol";

contract ProxyTest is Test {
    LogicContract logicContract;
    ProxyContract proxyContract;

    function setUp() public {
        // 部署逻辑合约
        logicContract = new LogicContract();
        // 部署代理合约并传入逻辑合约地址
        proxyContract = new ProxyContract(address(logicContract));
    }

    function test_IncrementViaDelegateCall() public {
        // 初始状态检查
        assertEq(proxyContract.counter(), 0, "Proxy counter should start at 0");
        assertEq(logicContract.counter(), 0, "Logic counter should start at 0");

        // 通过代理合约调用 increment
        uint256 newValue = proxyContract.incrementViaDelegateCall();

        // 验证返回值
        assertEq(newValue, 1, "Return value should be 1");
        // 验证代理合约状态更新
        assertEq(proxyContract.counter(), 1, "Proxy counter should be 1");
        // 验证逻辑合约状态未变
        assertEq(logicContract.counter(), 0, "Logic counter should still be 0");

        // 再次调用并验证
        newValue = proxyContract.incrementViaDelegateCall();
        assertEq(newValue, 2, "Return value should be 2");
        assertEq(proxyContract.counter(), 2, "Proxy counter should be 2");
        assertEq(logicContract.counter(), 0, "Logic counter should still be 0");
    }

    function test_UpdateLogicAddress() public {
        // 部署一个新的逻辑合约
        LogicContract newLogicContract = new LogicContract();
        address newLogicAddress = address(newLogicContract);

        // 更新逻辑合约地址
        proxyContract.updateLogicAddress(newLogicAddress);

        // 验证地址已更新
        assertEq(proxyContract.logicContractAddress(), newLogicAddress, "Logic address should be updated");

        // 调用 increment 并验证仍能正常工作
        uint256 newValue = proxyContract.incrementViaDelegateCall();
        assertEq(newValue, 1, "Return value should be 1 after address update");
        assertEq(proxyContract.counter(), 1, "Proxy counter should be 1");
    }

    // 测试用例修改
    function test_RevertWhen_DelegateCallToZeroAddress() public {
        // 设置零地址（现在会先触发update的revert）
        vm.expectRevert("Zero address not allowed");
        proxyContract.updateLogicAddress(address(0));

        proxyContract.incrementViaDelegateCall();
    }

    function test_RevertWhen_UpdateToZeroAddress() public {
        vm.expectRevert("Zero address not allowed");
        proxyContract.updateLogicAddress(address(0));
    }

    function testRevertWhen_DeployWithZeroAddress() public {
        vm.expectRevert("Zero address not allowed");
        new ProxyContract(address(0));
    }

    // 测试 delegatecall 调用不存在的函数
    function test_RevertWhen_DelegateCallToInvalidFunction() public {
        InvalidLogic invalidLogic = new InvalidLogic();
        proxyContract.updateLogicAddress(address(invalidLogic));

        vm.expectRevert("Delegatecall failed");
        proxyContract.incrementViaDelegateCall();
    }
}

// 用于测试的无效逻辑合约
contract InvalidLogic {
    uint256 public counter;
    // 故意不实现 increment 函数
}
