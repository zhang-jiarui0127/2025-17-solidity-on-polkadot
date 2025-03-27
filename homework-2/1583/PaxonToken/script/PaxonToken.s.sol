// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {PaxonToken} from "../src/PaxonToken.sol";

contract PaxonTokenScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        PaxonToken token = new PaxonToken("Paxon Token", "PAX", 18, 1000);

        vm.stopBroadcast();
    }
}
