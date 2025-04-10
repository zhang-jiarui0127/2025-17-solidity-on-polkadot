import { loadContractData } from "./loadContractData.js";
import { ethers } from "ethers";
import dotenv from 'dotenv';
dotenv.config();

const RPC_URL = process.env.RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY=process.env.PUBLIC_KEY



// 主执行函数
export async function ethersMethod() {
  
  // 1. 准备合约数据
  const { abi, bytecode } = loadContractData();

  
  // 2. 连接网络
  const provider = new ethers.JsonRpcProvider(RPC_URL);
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

  const balance = await provider.getBalance(
    PUBLIC_KEY
  );
console.log(`${PUBLIC_KEY}金额：${balance}`)
const feeData = await provider.getFeeData()
console.log(feeData)
    console.log(`部署网络：${RPC_URL}`);
  // 3. 部署合约
  console.log("ethers开始部署合约...");
  const factory = new ethers.ContractFactory(abi, bytecode, wallet);
  const contract = await factory.deploy({
 /*    maxFeePerGas: feeData.maxFeePerGas,              
    maxPriorityFeePerGas: feeData.maxPriorityFeePerGas, 
    gasPrice: feeData.gasPrice,
    gasLimit: 21000n, */
   
  });
  await contract.waitForDeployment();
  const contractAddress = await contract.getAddress();
  console.log("✅ 合约部署成功，地址:", contractAddress);

  // 4. 监听存储事件
/*   contract.on("NumberStored", (sender, value) => {
    console.log("\n📢 捕获到存储事件:");
    console.log("  发送者:", sender);
    console.log("  存储值:", value.toString());
  }); */



  // 5. 写入数据
  console.log("\n🖊️ 正在写入数据 123...");
  const tx = await contract.store(123);
  await tx.wait();
  console.log("✅ 数据写入成功，交易哈希:", tx.hash);

  //打印事件
  const latestBlock = await provider.getBlockNumber();

  const fromBlock = latestBlock - 10 >= 0 ? latestBlock - 10 : 0;
  const toBlock = latestBlock;
  const logs = await contract.queryFilter('NumberStored', fromBlock, toBlock);
  logs.forEach(log => {
    console.log('event:', log.args);
  });

  // 6. 读取验证
  console.log("\n🔍 验证存储数据...");
  const storedValue = await contract.retrieve();
  console.log(
    storedValue == 123
      ? "✅ 验证通过，存储值为 123" 
      : "❌ 验证失败，值不匹配"
  );

  // 7. 清理事件监听
  contract.removeAllListeners();
}

