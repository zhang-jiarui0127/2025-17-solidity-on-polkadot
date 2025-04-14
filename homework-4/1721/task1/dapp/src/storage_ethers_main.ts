import { ethers } from "ethers";
import { getEtherClient, getEtherWallet } from "./wallet";
import { ABI, BYTECODE } from "./storage";

async function main() {
    // 获取provider和wallet
    const provider = getEtherClient();
    const wallet = getEtherWallet(provider);

    // 创建合约工厂
    const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet);

    console.log("开始部署Storage合约...");
    
    // 部署合约
    const contract = await factory.deploy();
    await contract.waitForDeployment();
    
    const contractAddress = contract.target.toString();
    console.log("Storage合约已部署到地址:", contractAddress);

    // 创建合约实例
    const storageContract = new ethers.Contract(contractAddress, ABI, wallet);

    // 调用合约方法示例
    console.log("测试合约功能...");
    
    // 存储数值
    const storeValue = 42;
    const tx = await storageContract.store(storeValue);
    await tx.wait();
    console.log(`已存储数值: ${storeValue}`);

    // 读取数值
    const value = await storageContract.retrieve();
    console.log(`读取到的数值: ${value}`);

    // 添加区块监听
    console.log("开始监听新区块...");
    provider.on("block", (blockNumber) => {
        console.log(`新区块: ${blockNumber}`);
    });

    // 5秒后停止监听
    setTimeout(() => {
        provider.removeAllListeners();
        console.log("停止监听区块");
        process.exit(0);
    }, 5000);
}

main().catch((error) => {
    console.error("部署过程中发生错误:", error);
    process.exit(1);
});