// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Logic} from "../src/Logic.sol";
import {Proxy} from "../src/Proxy.sol";

contract ProxyTest is Test {
    Logic logic;
    Proxy proxy;

    function setUp() public {
        // 部署逻辑合约
        logic = new Logic();
        // 部署代理合约并传入逻辑合约地址
        proxy = new Proxy(address(logic));
    }

    function testIncrementThroughProxy() public {
        // 初始状态检查
        assertEq(proxy.counter(), 0);
        assertEq(logic.counter(), 0);

        // 通过代理调用increment
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Call failed");

        // 验证代理合约中的counter增加了
        assertEq(proxy.counter(), 1);
        // 验证逻辑合约中的counter未改变
        assertEq(logic.counter(), 0);

        // 再次调用
        (success, ) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Call failed");

        // 验证代理合约中的counter变为2
        assertEq(proxy.counter(), 2);
        // 逻辑合约的counter仍为0
        assertEq(logic.counter(), 0);
    }
}
