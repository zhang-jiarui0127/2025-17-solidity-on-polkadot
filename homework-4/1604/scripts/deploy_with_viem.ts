import { createPublicClient, createWalletClient, defineChain, hexToBigInt, http, getContract } from "viem"
import { privateKeyToAccount } from "viem/accounts"
// import solc from 'solc';
import path from 'path';
import fs from 'fs';

export const localChain = (url: string) => defineChain({
  id: 31337,
  name: 'Testnet',
  network: 'Testnet',
  nativeCurrency: {
      name: 'ETH',
      symbol: 'ETH',
      decimals: 18,
  },
  rpcUrls: {
      default: {
          http: [url],
      },
  },
  testnet: true,
})

// 这里是您的账户私钥
const PRIVATE_KEY = '0x5fb92d6e98884f76de468fa3f6278f8807c48bebc13595d45af5bdc4da702133'; // 请替换为您的私钥

async function deploy(contractName: string, args: any[]) {
  // 读取 ABI 和字节码
  const contractPath = path.join(__dirname, `../artifacts-pvm/contracts/${contractName}.sol/${contractName}.json`);
  const contractData = fs.readFileSync(contractPath, 'utf8');
  const parsedData = JSON.parse(contractData);

  // 检查合约数据是否有效
  if (!parsedData || !parsedData.evm || !parsedData.evm.bytecode) {
    throw new Error(`Invalid contract data: ${contractPath}`);
  }

  const bytecode = parsedData.evm.bytecode.object; // 使用 bytecode 字段
  const abi = parsedData.abi;

  // 使用私钥创建钱包
  const wallet = privateKeyToAccount(PRIVATE_KEY)
  const address = wallet.address


  // 创建钱包客户端，连接到本地节点
  const url = "http://127.0.0.1:8545"
  const client = createWalletClient({
    account: wallet,
    transport: http(), 
    chain: localChain(url), 
  });

  // 部署合约
  // const tx = await client.sendTransaction({
  //   account: wallet,
  //   to: undefined, // 部署时没有目标地址
  //   data: `0x${bytecode}` as `0x${string}`,
  // });
  const contract = await client.deployContract({
    abi: abi,
    bytecode: bytecode,
    args: [0]
  })
  console.log('Contract deployment result:', contract);

  // 等待交易完成
  const publicClient = createPublicClient({
    transport: http(),
    chain: localChain(url),
  });
  const nonce = await publicClient.getTransactionCount({ address: address })
  const txHash = await client.sendTransaction({ to: "0x5GNJqTPyNqANBkUVMN1LPPrxXnFouWXoe2wNSmmEoLctxiZY", value: hexToBigInt('0x10000') })
  const receipt = await publicClient.waitForTransactionReceipt({ hash: contract });
  return receipt.contractAddress;
}

(async () => {
  try {
    const address = await deploy('Storage', []);
    console.log(`Contract deployed at address: ${address}`);
  } catch (e) {
    if (e instanceof Error) {
      console.log(e.message);
    } else {
      console.log('An unknown error occurred:', e);
    }
  }
})();
