// viem-example.js
import { createPublicClient, createWalletClient, http } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { sepolia } from "viem/chains";

// 模拟编译后的合约数据 (实际项目中从 JSON 文件导入)
const contractData = {
  abi: [
    {
      "inputs": [],
      "name": "retrieve",
      "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "uint256", "name": "_number", "type": "uint256"}],
      "name": "store",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "anonymous": false,
      "inputs": [
        {"indexed": true, "internalType": "uint256", "name": "oldNumber", "type": "uint256"},
        {"indexed": true, "internalType": "uint256", "name": "newNumber", "type": "uint256"}
      ],
      "name": "NumberSet",
      "type": "event"
    }
  ],
  bytecode: "0x608060405234801561001057600080fd5b50610150806100206000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c80632e64cec11461003b5786057fd5e14610055575b600080fd5b610043610073565b60405161004c91906100d9565b60405180910390f35b61005d61007c565b60405161006a91906100d9565b60405180910390f35b60008054905090565b600080548190600101549091505090565b6000819050919050565b61009f8161008c565b82525050565b60006020820190506100ba6000830184610096565b92915050565b60008115159050919050565b6100d5816100c0565b82525050565b60006020820190506100f060008301846100cc565b9291505056fea2646970667358221220b1f1f6e6b1b6b1b6b1b6b1b6b1b6b1b6b1b6b1b6b1b6b1b6b1b6b1b6b1b6b1b6b1b6c64736f6c63430008110033"
};

async function main() {
  // 1. 配置账户和客户端
  const account = privateKeyToAccount(process.env.PRIVATE_KEY || "0xac0974bec39a17e36ba4a6b4d238ff944bac