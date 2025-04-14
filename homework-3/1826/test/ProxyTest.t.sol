// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import "../src/ProxyContract.sol";
import "../src/LogicContract.sol";

contract ProxyTest is Test {
    function testProxy() public {
        // 部署合约
        LogicContract logic = new LogicContract();
        ProxyContract proxy = new ProxyContract(address(logic));

        // 初始状态检查
        assertEq(proxy.counter(), 0);
        assertEq(logic.counter(), 0);

        // call调用increment函数
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Call failed");

        // 检查counter是否增加了1
        assertEq(logic.counter(), 0);
        // 检查代理合约的counter是否为0
        assertEq(proxy.counter(), 1);
        // 检查代理合约的逻辑合约地址是否正确
        assertEq(proxy.logicContract(), address(logic));
        console.log("logic.counter:", logic.counter());
        console.log("proxy.counter:", proxy.counter());
    }
}
