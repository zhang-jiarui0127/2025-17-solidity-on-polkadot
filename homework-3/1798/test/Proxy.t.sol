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
        uint256 proxycounter = proxy.counter();
        uint256 logiccounter = logic.counter();

        assertEq(proxycounter, 0, "init proxycounter is 0");
        assertEq(logiccounter, 0, "init logiccounter is 0");

        proxy.proxyIncrement();

        uint256 incrProxycounter = proxy.counter();
        uint256 incrLogiccounter = logic.counter();

        assertEq(incrProxycounter, proxycounter + 1, "incrProxycounter is 1");

        assertEq(incrLogiccounter, logiccounter, "incrLogiccounter is 0 ");
    }
}
