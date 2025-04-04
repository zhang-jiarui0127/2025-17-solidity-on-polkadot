// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Logic} from "../src/Counter.sol";
import {Proxy} from "../src/Counter.sol";

contract CounterScript is Script {
    // Deploys the Logic and Proxy contracts
    Logic public logic;
    Proxy public proxy;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        logic = new Logic();
        proxy = new Proxy();

        vm.stopBroadcast();
    }
}
