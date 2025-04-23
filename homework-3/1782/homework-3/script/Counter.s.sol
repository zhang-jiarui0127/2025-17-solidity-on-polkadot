// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Proxy} from "../src/Proxy.sol";
import {Logic} from "../src/Logic.sol";

contract CounterScript is Script {
    Proxy public proxy;
    Logic public logic;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // 部署 Logic 逻辑合约
        logic = new Logic();

        // 部署 Proxy 代理合约
        proxy = new Proxy();

        vm.stopBroadcast();
    }
}
