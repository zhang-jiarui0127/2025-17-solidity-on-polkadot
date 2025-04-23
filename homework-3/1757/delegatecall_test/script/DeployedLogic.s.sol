// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import {Logic} from "../src/logic.sol";
import {Proxy} from "../src/proxy.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployedLogic is Script {
    function run()  external returns (Logic logic, Proxy proxy) {
        vm.startBroadcast();
        logic = new Logic();

        proxy = new Proxy(address(logic));
        vm.stopBroadcast();
        console.log("Logic deployed at", address(logic));
        console.log("Proxy deployed at", address(proxy));
    }
}
