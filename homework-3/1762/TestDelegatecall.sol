// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "LogicContract.sol";
import "ProxyContract.sol";

contract TestDelegatecall {
    LogicContract logic;
    ProxyContract proxy;

    function beforeAll() public {
        logic = new LogicContract();
        proxy = new ProxyContract(address(logic));
    }

    function testInitialCountIsZero() public {
        uint256 initCount = proxy.count();
        Assert.equal(initCount, 0, "初始 count 应为 0");
    }

    function testIncrementThroughDelegatecall() public {

        (bool success, ) = address(proxy).call(abi.encodeWithSignature("increment()"));
        Assert.ok(success, "调用 increment 应该成功");

        uint256 countAfter = proxy.count();
        Assert.equal(countAfter, 1, "调用一次后 count 应为 1");
    }
}
