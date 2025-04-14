pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Proxy, Logic} from "../contracts/contract_demo.sol";

contract ProxyTest {
    Proxy public proxy;
    Logic public logic;

    function setUp() public {
        logic = new Logic();
        proxy = new Proxy(address(logic));
    }

    function testIncrCount() public {
        uint256 initialCount = proxy.count();

        // 计算 incr 方法的函数选择器
        bytes4 selector = bytes4(keccak256("incr()"));
        (bool success, ) = address(proxy).call(abi.encodeWithSelector(selector));
        require(success, "Call to proxy failed");

        Assert.equal(initialCount + 1, proxy.count(), "Proxy count should be incremented");

        Assert.equal(initialCount, logic.count(), "Logic contract count should be the same as proxy count");
    }
}
