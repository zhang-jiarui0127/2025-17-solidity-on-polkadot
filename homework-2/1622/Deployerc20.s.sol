// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/erc20.sol";

contract DeployERC20 is Script {
    function run() external {
        // // 从环境变量中获取私钥
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // 开始广播交易（使用私钥签名）
        //m.startBroadcast(deployerPrivateKey);
        vm.startBroadcast();
        // 部署 SimpleERC20 合约
        SimpleERC20 token = new SimpleERC20("SimpleToken", "STK", 1000);

        // 打印合约地址
        console.log("Deployed SimpleERC20 at:", address(token));

        // 停止广播交易
        vm.stopBroadcast();
    }
}
