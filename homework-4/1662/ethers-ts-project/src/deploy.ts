import { ethers } from "ethers";
import * as fs from "fs";
import * as path from "path";
import 'dotenv/config';

async function main() {
  const url = process.env.RPC_URL;
  const provider = new ethers.JsonRpcProvider(url);
  const blockNumber = await provider.getBlockNumber();

  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) {
    throw new Error('Private key is not defined');
  }

  const wallet = new ethers.Wallet(privateKey, provider);
  console.log(`当前区块高度: ${blockNumber}`);
  
  // 读取编译后的合约数据（关键）
  const artifactPath = path.join(__dirname, "../src/abi/StorageContract.json");
  // 如果使用 solcjs 编译，路径可能是这样的：
  //const artifactPath = path.join(__dirname, "../artifacts/src/Storage_sol_Storage.json");
  const contractJSON = JSON.parse(fs.readFileSync(artifactPath, "utf8"));
  const abi = contractJSON.abi;
  const bytecode = contractJSON.bytecode.object || contractJSON.bytecode;
  
  // 创建合约工厂
  const factory = new ethers.ContractFactory(abi, bytecode, wallet);
  
  console.log("开始部署 Storage 合约...");
  const contract = await factory.deploy();
  
  // 等待合约部署完成
  const tx = contract.deploymentTransaction();
  if (tx) {
    await tx.wait();
  } else {
    throw new Error('部署交易为空');
  }
  
  console.log(`Storage 合约已部署到地址: ${contract.target}`);
  
  // 测试合约功能
  console.log("测试合约存储功能...");
  const storeTx = await (contract as any).store(42);
  await storeTx.wait();
  
  const value = await (contract as any).retrieve();
  console.log(`存储的值: ${value}`);
  
  // 添加事件监听逻辑
  console.log("开始监听合约事件...");
  
  // 检查合约 ABI 中是否存在事件定义
  const events = contractJSON.abi.filter((item: any) => item.type === 'event');
  
  if (events.length > 0) {
    console.log("合约中定义的事件:");
    events.forEach((event: any) => {
      console.log(`- ${event.name}`);
      
      // 监听找到的每个事件
      contract.on(event.name, (...args) => {
        const eventData = args.slice(0, -1); // 最后一个参数是事件对象
        const eventObj = args[args.length - 1];
        
        console.log(`检测到 ${event.name} 事件:`);
        console.log(`  参数: ${JSON.stringify(eventData)}`);
        console.log(`  交易哈希: ${eventObj.log.transactionHash}`);
      });
    });
  } else {
    console.log("合约中没有定义任何事件，无法监听特定事件");
  }
  
  // 尝试使用通用方式监听所有事件
  try {
    provider.on({ address: contract.target }, (log) => {
      console.log("检测到合约交互:");
      console.log(`  交易哈希: ${log.transactionHash}`);
      console.log(`  区块号: ${log.blockNumber}`);
      console.log(`  数据: ${log.data}`);
    });
    console.log(`正在监听地址 ${contract.target} 的所有交易...`);
  } catch (error) {
    console.error("设置通用事件监听时出错:", error);
  }
  
  console.log("事件监听已设置，等待事件发生...");
  console.log("请在另一个终端中与合约交互以触发事件");
  console.log("按 Ctrl+C 停止监听");
  
  // 保持脚本运行以继续监听事件
  // 这里使用一个简单的方法让脚本保持运行
  await new Promise(() => {});
}

main().catch((error) => {
  console.error("部署过程中出错:", error);
  process.exit(1);
});
