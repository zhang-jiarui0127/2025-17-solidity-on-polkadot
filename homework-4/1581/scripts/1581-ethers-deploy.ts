import { ethers } from "hardhat";

async function main() {
    // 部署合约
    const Storage = await ethers.getContractFactory("Storage");
    const storage = await Storage.deploy();
    await storage.deployed();
    console.log("Storage deployed to:", storage.address);

    // 调用 store 函数
    const tx = await storage.store(42);
    await tx.wait();
    console.log("Stored 42");

    // 查询 retrieve 函数
    const number = await storage.retrieve();
    console.log("Retrieved number:", number.toString());

    // 监听 NumberUpdated 事件
    storage.on("NumberUpdated", (newNumber) => {
        console.log("Event NumberUpdated:", newNumber.toString());
    });

    // 再次调用 store 触发事件
    await storage.store(100);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});