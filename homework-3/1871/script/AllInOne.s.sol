// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Logic} from "../src/Logic.sol";
import {Proxy} from "../src/Proxy.sol";

contract AllInOneScript is Script {

    function setUp() public {}

    function run() public returns (Logic logic, Proxy proxy) {
        vm.startBroadcast();

        logic = new Logic();
        proxy = new Proxy();

        vm.stopBroadcast();
    }
}
