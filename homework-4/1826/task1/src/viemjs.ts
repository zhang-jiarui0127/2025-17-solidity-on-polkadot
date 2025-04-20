import {
  createPublicClient,
  http,
  defineChain,
  createWalletClient,
  decodeEventLog,
} from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { encodeFunctionData, decodeFunctionResult } from 'viem/utils';
import { ABI, BYTECODE } from './storageAbi_bytecode';

export const localChain = (url: string) =>
  defineChain({
    id: 31337, //Anvil默认的链ID
    name: 'Testnet',
    network: 'Testnet',
    nativeCurrency: { name: 'ETH', symbol: 'ETH', decimals: 18 },
    rpcUrls: {
      default: {
        http: [url],
      },
    },
    testnet: true,
  });
async function main() {
  const url = 'http://127.0.0.1:8545';
  // 创建客户端(只读)
  const publicClient = createPublicClient({
    chain: localChain(url),
    transport: http(),
  });

  const privateKey =
    '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';
  const wallet = privateKeyToAccount(privateKey);

  // 钱包
  const walletClient = createWalletClient({
    chain: localChain(url),
    transport: http(),
    account: wallet, // 使用私钥或钱包签名
  });

  const block = await publicClient.getBlock();
  console.log('当前区块高度:', block.number);

  // 部署合约
  const deployHash = await walletClient.deployContract({
    abi: ABI,
    account: wallet,
    bytecode: `0x${BYTECODE}`,
  });
  console.log('此为交易哈希  ', deployHash);

  // 获取合约地址
  const receipt = await publicClient.waitForTransactionReceipt({
    hash: deployHash,
  });
  console.log('获取合约地址: ', receipt.contractAddress);
  const getMyContract = receipt.contractAddress;
  if (!getMyContract) {
    throw new Error('Contract address is null or undefined');
  }

  // 调用合约写入方法
  async function callContractMethod(
    contractAddress: `0x${string}`,
    methodName: string
  ) {
    const contractSetNum = await walletClient.writeContract({
      address: contractAddress,
      abi: ABI,
      functionName: methodName,
      args: [999],
    });
    return contractSetNum;
  }

  // 监听事件
  const unwatchOld = publicClient.watchContractEvent({
    address: getMyContract,
    abi: ABI,
    eventName: 'oldNum',
    onLogs: (logs) => {
      logs.forEach((log) => {
        const decoded = decodeEventLog({
          abi: ABI,
          eventName: 'oldNum',
          data: log.data,
          topics: log.topics,
        });
        const res = decoded.args;
        console.log('监听到oldNum：  ', res);
      });
    },
  });
  const unwatchNew = publicClient.watchContractEvent({
    address: getMyContract,
    abi: ABI,
    eventName: 'NumChanged',
    onLogs: (logs) => {
      logs.forEach((log) => {
        const decoded = decodeEventLog({
          abi: ABI,
          eventName: 'NumChanged',
          data: log.data,
          topics: log.topics,
        });
        const res = decoded.args;
        console.log('监听到NumChanged：  ', res);
      });
    },
  });
  callContractMethod(getMyContract, 'setNumber');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
