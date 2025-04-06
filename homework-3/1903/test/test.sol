// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../contracts/Logic.sol";
import "../contracts/Proxy.sol";

contract TestProxyContract {
    Logic logic;
    Proxy proxy;

    event TestEvent(string message, bool success);

    constructor() {
        logic = new Logic();
        proxy = new Proxy(address(logic)); 
    }

    function testDelegateCall() public {
        // 初始状态验证
        require(proxy.count() == 0, "Proxy initial count should be 0");
        require(logic.count() == 0, "Logic initial count should be 0");

        // 执行代理调用
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature("delegatedIncrement()")
        );
        require(success, "Delegatecall failed");

        // 验证状态变化
        require(proxy.count() == 1, "Proxy count should be 1");
        require(logic.count() == 0, "Logic count should remain 0");

        emit TestEvent("All tests passed", true);
    }
}
