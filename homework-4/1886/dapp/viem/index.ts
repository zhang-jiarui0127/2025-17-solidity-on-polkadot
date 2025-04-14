import { readFileSync } from "node:fs";

import {
  createPublicClient,
  createWalletClient,
  defineChain,
  hexToBigInt,
  http,
} from "viem";
import { privateKeyToAccount } from "viem/accounts";

const ABI = readFileSync("../ABI/Storage.abi", "utf-8");
const BIN = readFileSync("../BIN/Storage.bin", "binary");

const localChain = (url: string) =>
  defineChain({
    id: 31337,
    name: "Testnet",
    network: "Testnet",
    nativeCurrency: {
      name: "ETH",
      symbol: "ETH",
      decimals: 18,
    },
    rpcUrls: {
      default: {
        http: [url],
      },
    },
    testnet: true,
  });

async function main() {
  const url = "http://localhost:8545";
  const publicClient = createPublicClient({
    chain: localChain(url),
    transport: http(),
  });
  const blockNumber = await publicClient.getBlockNumber();
  const privateKey =
    "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
  const wallet = privateKeyToAccount(privateKey);
  const walletAddress = wallet.address;

  //   console.log("Wallet Address:", walletAddress);

  const balance = await publicClient.getBalance({
    address: walletAddress,
  });

  const walletClient = createWalletClient({
    account: wallet,
    chain: localChain(url),
    transport: http(),
  });
  const tx = await walletClient.sendTransaction({
    account: wallet,
    to: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
    value: hexToBigInt("0x1"),
  });

  //   console.log("Transaction Hash:", tx);

  const txTwo = await walletClient.deployContract({
    abi: JSON.parse(ABI),
    bytecode: `0x${BIN}`,
    args: [],
  });

  //   console.log("Contract Address:", txTwo);

  const receipt = await publicClient.waitForTransactionReceipt({ hash: txTwo });
  const contractAddress = receipt.contractAddress;
  //   console.log("Contract Address:", contractAddress);

  if (
    typeof contractAddress !== "string" ||
    !contractAddress.startsWith("0x")
  ) {
    throw new Error("Contract address is not a string");
  }

  const retrieve = await publicClient.readContract({
    address: contractAddress,
    abi: JSON.parse(ABI),
    functionName: "retrieve",
    args: [],
  });

  //   console.log("Retrieve:", retrieve);

  const store = await walletClient.writeContract({
    address: contractAddress,
    abi: JSON.parse(ABI),
    functionName: "store",
    args: [123456],
  });

  //   console.log(
  //     "Retrieve after store:",
  //     await publicClient.readContract({
  //       address: contractAddress,
  //       abi: JSON.parse(ABI),
  //       functionName: "retrieve",
  //       args: [],
  //     })
  //   );

  publicClient.watchBlockNumber({
    onBlockNumber: async (blockNumber) => {
      console.log("Block Number:", blockNumber);
    },
  });
}

main();
