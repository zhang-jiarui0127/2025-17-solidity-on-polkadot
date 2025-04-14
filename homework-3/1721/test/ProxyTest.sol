// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Logic.sol";
import "../src/Proxy.sol";

// 代理合约测试
contract ProxyTest is Test {
    Logic public logic;
    Proxy public proxy;
    Logic public proxyAsLogic;

    function setUp() public {
        logic = new Logic();
        proxy = new Proxy(address(logic));

        // 让代理合约 `proxy` 以 `Logic` 的 ABI 交互
        proxyAsLogic = Logic(address(proxy));
    }

    function testIncrementThroughProxy() public {
        proxyAsLogic.increment();
        uint256 count = proxyAsLogic.count();
        assertEq(count, 1, "Count should be 1 after incrementing through proxy");
    }

    function testUpgradeImplementation() public {
        Logic newLogic = new Logic();
        proxy.upgrade(address(newLogic));
        assertEq(proxy.getImplementation(), address(newLogic), "Implementation should be updated");
    }
}
