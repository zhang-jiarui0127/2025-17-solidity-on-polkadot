import { getViemClient, getViemWalletClient } from "./src/wallet";
import { ABI, BYTECODE } from "./src/erc20";
import { formatEther , getContract } from 'viem';
import {deployContract, } from 'viem/actions'

async function main() {
    const client = await getViemClient();

    // 获取当前区块号
    const blockNumber = await client.getBlockNumber()
    console.log("blockNumber:", `${blockNumber}`)

    // walletClient
    const walletClient = await getViemWalletClient();
    console.log("wallet.address", walletClient.account.address);

    // balance
    const balance =  await client.getBalance(walletClient.account);
    console.log(`balance is ${balance}`)
    console.log(`balance is ${formatEther(balance)} ETH`);

    // const contractAddress = await deployContract(walletClient, {
    //     abi: ABI,
    //     bytecode: `0x${BYTECODE}`,
    //     account: walletClient.account.address, 
    // })

    const txHash = await deployContract(walletClient, {
        abi: ABI,
        bytecode: `0x${BYTECODE}`,
        account: walletClient.account.address, 
    });
    console.log(`Contract deployment transaction sent! Hash: ${txHash}`);
    
    // 等待交易被确认并获取收据
    const receipt = await client.waitForTransactionReceipt({
        hash: txHash as `0x${string}`,
    });
    
    // // 从收据中获取合约地址
    const contractAddress = receipt.contractAddress;

    console.log(`·Contract deployed successfully! Address: ${contractAddress}`);
    if (!contractAddress || !contractAddress.startsWith('0x') || contractAddress.length !== 42) {
        throw new Error(`Invalid contract address: ${contractAddress}`);
    }
    
    // 1. Create contract instance
    const contract = getContract({
        address: contractAddress,
        abi: ABI,
        // 1a. Insert a single client
        // client: client,
        // 1b. Or public and/or wallet clients
        client: { public: client, wallet: walletClient }
    });

    // write
    try {
        const txHash = await contract.write.store([123456]);
        console.log("Transaction hash:", txHash);
    } catch (error) {
        console.error("Error sending transaction:", error);
    }

    // read
    try {
        const value = await contract.read.retrieve();
        console.log(`Stored value: ${value}`);
    } catch (error) {
        console.error("Error reading value:", error);

    }
}

main()
