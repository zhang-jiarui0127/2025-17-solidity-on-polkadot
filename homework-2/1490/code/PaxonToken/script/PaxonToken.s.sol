// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {PaxonToken} from "../src/PaxonToken.sol";

contract PaxonTokenScript is Script {
    PaxonToken public paxonToken;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        console.log("deploy deployerAddress:", address(deployerAddress));
        vm.startBroadcast(deployerPrivateKey);

        paxonToken = new PaxonToken("Paxon Token", "PAX", 18, 1000);
        console.log("PaxonToken deployed to:", address(paxonToken));

        vm.stopBroadcast();
    }
}
