// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {LogicCounter} from "../src/LogicCounter.sol";

contract CounterScript is Script {
    LogicCounter public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        counter = new LogicCounter();

        vm.stopBroadcast();
    }
}
