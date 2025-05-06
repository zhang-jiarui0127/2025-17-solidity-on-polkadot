// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "./Coursework3.sol";

contract CourseworkTest {
    LogicContract logic;
    ProxyContract proxy;

    function setUp() public {
        logic = new LogicContract();
        proxy = new ProxyContract(address(logic));
    }

    function testIncrementViaDelegateCall() public {
        // 初始状态检查
        require(proxy.counter() == 0, "Initial counter should be 0");

        // 调用 increment
        proxy.callIncrement();
        require(proxy.counter() == 1, "Counter should be 1");

        // 再次调用
        proxy.callIncrement();
        require(proxy.counter() == 2, "Counter should be 2");

        // 检查逻辑合约状态未变
        require(logic.counter() == 0, "Logic counter should be 0");
    }

    function run() public {
        setUp();
        testIncrementViaDelegateCall();
    }
}