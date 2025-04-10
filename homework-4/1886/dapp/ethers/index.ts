import { readFileSync } from "node:fs";

import { ethers } from "ethers";
import type { TransactionRequest } from "ethers";

const ABI = readFileSync("../ABI/Storage.abi", "utf-8");
const BIN = readFileSync("../BIN/Storage.bin", "binary");

async function main() {
  const url = "http://localhost:8545";
  const provider = new ethers.JsonRpcProvider(url);
  const blockNumber = await provider.getBlockNumber();

  //   console.log("Current block number:", blockNumber);

  const privateKey =
    "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
  const wallet = new ethers.Wallet(privateKey, provider);
  const walletAddress = wallet.address;

  //   console.log("Wallet address:", walletAddress);

  const balance = await provider.getBalance(walletAddress);
  const nonce = await provider.getTransactionCount(walletAddress);

  //   console.log("Nonce:", nonce);

  const transfer: TransactionRequest = {
    to: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
    value: "1",
  };

  const tx = await wallet.sendTransaction(transfer);
  await tx.wait();
  const hash = tx.hash;

  //   console.log("Transaction hash:", hash);

  const factory = new ethers.ContractFactory(ABI, BIN, wallet);
  const contract = await factory.deploy();
  await contract.waitForDeployment();
  const contractAddress = await contract.target.toString();

  // console.log("Contract address:", contractAddress);

  const readContract = new ethers.Contract(contractAddress, ABI, provider);
  const retrieve = await readContract.retrieve();

  // console.log("Retrieve:", retrieve);

  const writeContract = new ethers.Contract(contractAddress, ABI, wallet);
  const store = await writeContract.store(123456);
  await store.wait();

  // console.log("Retrieve after store:", await readContract.retrieve());

  provider.on("block", async (blockNumber) => {
    console.log("Block number:", blockNumber);

    if (blockNumber > 20) {
      provider.off("block");
      console.log("Unsubscribed from block events");
    }
  });
}

main();
