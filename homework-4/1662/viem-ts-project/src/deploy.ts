import { createPublicClient, createWalletClient, http } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { foundry } from 'viem/chains';
import { readFileSync } from 'fs';
// 使用 require 导入 solc
const solc = require('solc');


const RPC_URL = 'http://127.0.0.1:8545';
const PRIVATE_KEY = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';

function compileContract(filePath: string) {
  const source = readFileSync(filePath, 'utf8');
  const input = {
    language: 'Solidity',
    sources: {
      'Storage.sol': { content: source },
    },
    settings: { outputSelection: { '*': { '*': ['abi', 'evm.bytecode'] } } },
  };

  const output = JSON.parse(solc.compile(JSON.stringify(input)));
  const contract = output.contracts['Storage.sol'].Storage;

  return {
    abi: contract.abi,
    bytecode: `0x${contract.evm.bytecode.object}`,
  };
}

// 修改 deployContract 函数，接收 walletClient 和 publicClient 两个参数
async function deployContract(
  walletClient: any, 
  publicClient: any, 
  abi: any[], 
  bytecode: `0x${string}`
) {
  const hash = await walletClient.deployContract({ abi, bytecode, args: [] });
  // 使用 publicClient 来等待交易确认
  const receipt = await publicClient.waitForTransactionReceipt({ hash });

  if (!receipt.contractAddress) throw new Error('部署失败，未获取合约地址');
  return receipt.contractAddress;
}

async function main() {
  const account = privateKeyToAccount(PRIVATE_KEY);

  const publicClient = createPublicClient({
    chain: foundry,
    transport: http(RPC_URL),
  });

  const walletClient = createWalletClient({
    account,
    chain: foundry,
    transport: http(RPC_URL),
  });

  const { abi, bytecode } = compileContract('./src/Storage.sol');
  console.log('正在部署 Storage 合约...');

  // 修改调用方式，传入 walletClient 和 publicClient
  const contractAddress = await deployContract(
    walletClient, 
    publicClient, 
    abi, 
    bytecode as `0x${string}`
  );
  console.log('合约已部署到地址:', contractAddress);

  console.log('监听 store 函数调用事件...');
  const unwatch = publicClient.watchContractEvent({
    address: contractAddress,
    abi,
    onLogs: logs => console.log('检测到合约事件:', logs),
    onError: err => console.error('监听出错:', err),
  });

  console.log('调用 store(42)...');
  const txHash = await walletClient.writeContract({
    address: contractAddress,
    abi,
    functionName: 'store',
    args: [42],
  });

  await publicClient.waitForTransactionReceipt({ hash: txHash });

  const storedValue = await publicClient.readContract({
    address: contractAddress,
    abi,
    functionName: 'retrieve',
    args: [],
  });

  console.log('当前存储的值:', storedValue);
  console.log('监听将于 30 秒后停止...');
  await new Promise(res => setTimeout(res, 30000));
  unwatch();

  return contractAddress;
}

main()
  .then(addr => console.log('完成，合约地址:', addr))
  .catch(err => {
    console.error('出错:', err);
    process.exit(1);
  });
