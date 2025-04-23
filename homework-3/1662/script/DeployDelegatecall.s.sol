// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Delegatecall.sol";

contract DeployDelegatecall is Script {
    function run() external {
        // 从环境变量获取私钥
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // 从环境变量获取 Logic 合约地址
        address logicAddress = vm.envAddress("LOGIC_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 部署 Delegatecall 合约
        Delegatecall delegatecall = new Delegatecall(logicAddress);
        
        vm.stopBroadcast();
        
        console.log("Delegatecall contract deployed at:", address(delegatecall));
    }
}