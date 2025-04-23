// homework-4/ethers/main.ts
import { ethers, Wallet } from "ethers";
import { ABI, BYTECODE } from "./Storage";

const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

async function main() {
  const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");
  const wallet = new Wallet(privateKey, provider);

  // 部署合约
  const StorageFactory = new ethers.ContractFactory(ABI, BYTECODE, wallet);
  const storageContract = await StorageFactory.deploy(); // 如果构造函数无参数，可以省略参数
  await storageContract.waitForDeployment();
  console.log("Storage deployed at:", storageContract.target);

  // 监听事件
  storageContract.on("NumberChanged", (newData: ethers.BigNumberish) => {
    console.log("NumberChanged event detected! New data:", newData.toString());
  });

  // 调用 set 方法
  const setFunction = storageContract.getFunction("set");
  const tx = await setFunction(42);
  await tx.wait();
  console.log("Called set(42)");

  // 调用 get 方法
  const getFunc = storageContract.getFunction("get");
  const storedValue = await getFunc();
  console.log("Stored value:", storedValue.toString());
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});