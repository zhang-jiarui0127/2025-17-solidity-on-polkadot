// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Logic} from "../src/Logic.sol";
import {Proxy} from "../src/Proxy.sol";

contract ProxyTest is Test {
    Logic logic;
    Proxy proxy;

    function setUp() public {
        logic = new Logic();
        proxy = new Proxy(address(logic));
    }

    function testDelegatecallUpdatesProxyState() public {
        uint256 proxyCount = proxy.count();
        uint256 logicCount = logic.count();

        assertEq(proxyCount, 0, "init proxyCount is 0");
        assertEq(logicCount, 0, "init logicCount is 0");

        proxy.proxyIncrement();

        uint256 incrProxyCount = proxy.count();
        uint256 incrLogicCount = logic.count();

        assertEq(incrProxyCount, proxyCount + 1, "incrProxyCount is 1");

        assertEq(incrLogicCount, logicCount, "incrLogicCount is 0 ");
    }
}
