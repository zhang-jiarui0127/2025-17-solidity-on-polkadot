import { useIgnition } from "@nomicfoundation/hardhat-ignition";
import StorageModule from "./modules/Storage";  // 导入您的模块

async function main() {
  const ignition = useIgnition();

  // 使用 Hardhat Ignition 的模块
  const { storage } = await ignition.run(StorageModule);

  console.log("Contract deployed to:", storage.address);

  // 调用合约方法示例：存储一个值
  const tx = await storage.store(42);
  await tx.wait();
  console.log("Stored number 42!");

  // 获取存储的值
  const storedNumber = await storage.retrieve();
  console.log("Retrieved number:", storedNumber.toString());
}

main().catch((error) => {
  console.error("Error deploying contract:", error);
  process.exitCode = 1;
});
