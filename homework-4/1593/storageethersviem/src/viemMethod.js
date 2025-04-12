import { createWalletClient, createPublicClient, http,decodeEventLog } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import dotenv from 'dotenv';
import { loadContractData } from './loadContractData.js';

dotenv.config();

const RPC_URL = process.env.RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;

export async function viemMethod() {
  const { abi, bytecode } = loadContractData();
 /*  console.log('ABI 是否包含事件:', abi.find(x => x.type === 'event' && x.name === 'NumberStored')); */

  const account = privateKeyToAccount(`${PRIVATE_KEY}`);

  const publicClient = createPublicClient({
    transport: http(RPC_URL),
  });

  const walletClient = createWalletClient({
    account,
    transport: http(RPC_URL),
  });

  // 查询余额
  const balance = await publicClient.getBalance({
    address: PUBLIC_KEY,
  });
  console.log(`${PUBLIC_KEY} 金额: ${balance}`);

  // 获取 gas 数据
  const feeData = await publicClient.estimateGas({
    account,
    to: PUBLIC_KEY,
    value: 0n,
  });
  console.log('估算 Gas:', feeData);
  console.log(`部署网络：${RPC_URL}`);
  // 部署合约
  console.log('viem开始部署合约...');
  const hash = await walletClient.deployContract({
    abi,
    bytecode,
    args: [],
   // gas: 1_000_000n,
  });

  const receipt = await publicClient.waitForTransactionReceipt({ hash });
  const contractAddress = receipt.contractAddress;
  console.log('✅ 合约部署成功，地址:', contractAddress);

  // 写入数据 456
  console.log('\n🖊️ 正在写入数据 456...');
  const writeHash = await walletClient.writeContract({
    abi,
    address: contractAddress,
    functionName: 'store',
    args: [456n],
  });

  const writeReceipt = await publicClient.waitForTransactionReceipt({
    hash: writeHash,
  });
  console.log('✅ 数据写入成功，交易哈希:', writeHash);

  // ✨ 事件监听（从写入交易的 block 开始查找）
  console.log('\n📡 查询事件日志...');
  const logs = await publicClient.getLogs({
    address: contractAddress,

    fromBlock: writeReceipt.blockNumber, // 或 use: 'latest' if uncertain
    toBlock: writeReceipt.blockNumber,
  });

  logs.forEach((log) => {
    console.log('📢 捕获到存储事件:');
    const topics = decodeEventLog({
        abi:abi,
        eventName: 'NumberStored',
        data:log.data,
        topics:log.topics
      })
    console.log('事件数据:', topics);

  //  console.log('  存储值:', log.args.value.toString());
  });

  // 读取数据
  console.log('\n🔍 验证存储数据...');
  const storedValue = await publicClient.readContract({
    abi,
    address: contractAddress,
    functionName: 'retrieve',
  });

  console.log(
    storedValue === 456n
      ? '✅ 验证通过，存储值为 456'
      : `❌ 验证失败，值为 ${storedValue}`
  );
}
