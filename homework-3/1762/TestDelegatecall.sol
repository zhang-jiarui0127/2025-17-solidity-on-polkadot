// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入 Remix 测试库（Remix IDE 内置）
import "remix_tests.sol"; 

// 导入待测试的合约（路径根据实际情况调整）
import "../contracts/LogicContract.sol";
import "../contracts/ProxyContract.sol";

contract TestDelegatecall {
    LogicContract logic;
    ProxyContract proxy;

    // 在所有测试前执行，用于部署合约
    function beforeAll() public {
        // 部署逻辑合约
        logic = new LogicContract();
        // 部署代理合约，并传入逻辑合约地址
        proxy = new ProxyContract(address(logic));
    }

    // 测试初始状态下 count 是否为 0
    function testInitialCountIsZero() public {
        uint256 initCount = proxy.count();
        Assert.equal(initCount, 0, "初始 count 应为 0");
    }

    // 测试通过代理调用 increment 后，count 是否增加
    function testIncrementThroughDelegatecall() public {
        // 调用代理合约，由于代理合约中没有显式声明 increment 函数，
        // 需要通过低级调用（call）并传入逻辑合约的函数签名进行调用
        (bool success, ) = address(proxy).call(abi.encodeWithSignature("increment()"));
        Assert.ok(success, "调用 increment 应该成功");

        uint256 countAfter = proxy.count();
        Assert.equal(countAfter, 1, "调用一次后 count 应为 1");
    }
}
