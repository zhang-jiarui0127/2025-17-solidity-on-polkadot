// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Counter_LogicContract.sol";
import "../src/Counter_ProxyContract.sol";

contract DelegateCallScript is Script {
    function run() external {
        // 开始广播交易（使用 Foundry 的私钥）
        vm.startBroadcast();

        // 部署逻辑合约和代理合约
        LogicContract logic = new LogicContract();
        ProxyContract proxy = new ProxyContract();

        // 输出初始状态
        console.log("Initial Proxy Count:", proxy.count());
        console.log("Initial Logic Count:", logic.count());

        // 通过代理合约调用逻辑合约的 increment 函数
        proxy.delegateIncrement(address(logic));

        // 输出调用后的状态
        console.log("Updated Proxy Count:", proxy.count());
        console.log("Logic Count (should remain 0):", logic.count());

        // 停止广播交易
        vm.stopBroadcast();
    }
}