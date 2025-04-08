// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Logic.sol";
import "./Proxy.sol";

contract TestProxy {
    Logic public logic;
    Proxy public proxy;

    constructor() {
        logic = new Logic();
        proxy = new Proxy(address(logic));
    }

    // 测试状态保留
    function testStatePreservation() public {
        // 初始状态
        require(proxy.count() == 0, "Initial proxy count should be 0");
        require(logic.count() == 0, "Logic contract count should be 0");

        // 执行代理调用
        proxy.executeIncrement();

        // 验证代理状态更新
        require(proxy.count() == 1, "Proxy count should be 1");
        require(logic.count() == 0, "Logic count must remain 0");
    }
}