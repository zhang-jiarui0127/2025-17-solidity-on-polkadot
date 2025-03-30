// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PaxonToken} from "../src/PaxonToken.sol";  // 修正路径和合约名2

contract CounterScript is Script {
    PaxonToken public paxonToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        paxonToken = new PaxonToken(
            "Paxon Token",
            "PAX",
            18,
            1000000
        );

        vm.stopBroadcast();
    }
}
