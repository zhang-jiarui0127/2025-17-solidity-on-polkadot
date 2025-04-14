// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/demo/Counter.sol";
import "../src/demo/CounterProxy.sol";

contract CounterTest is Test {
    Counter public counter;
    Proxy public proxy;

    address admin = address(0x123);

    function setUp() public {
        //初始管理员身份
        proxy = new Proxy(address(0), admin);
        counter = new Counter();
        require(proxy.getAdmin() == admin, 'admin not eq in proxy');
        //counter的admin未赋值，和proxy中不同，所以counter的initialize方法onlyAdmin失败
        require(counter.getAdmin() != admin, 'admin not eq in counter');
        vm.prank(admin);   
        // counter.initialize(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.getNumber(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        //去掉onlyAdmin后测试
        counter.initialize(x);
        assertEq(counter.getNumber(), x);
    }
}
