// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Proxy} from "../src/Proxy.sol";
import {Logic} from "../src/Logic.sol";

contract ProxyTest is Test {
    Proxy public proxy;
    Logic public logic;

    function setUp() public {
        logic = new Logic();
        proxy = new Proxy();
    }

    function testDelegateCall() public {
        uint256 inputValue = 42;

        // 代理调用逻辑合约
        proxy.delegateSetNumber(address(logic), inputValue);

        // 断言：代理合约的 `_proxyNumber` 是否更新
        uint256 storedInProxy = proxy.proxyNumber();
        assertEq(storedInProxy, inputValue + 1, "Proxy storage should be updated");

        // 断言：逻辑合约的 `logicNumber` 是否未更新
        uint256 storedInLogic = logic.logicNumber();
        assertEq(storedInLogic, 0, "Logic contract storage should not be updated");
    }
}