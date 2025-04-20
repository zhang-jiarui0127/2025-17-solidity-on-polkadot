// viem-example.ts
import { createWalletClient, createPublicClient, http, parseEther } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { hardhat } from 'viem/chains';
import fs from 'fs';
import path from 'path';

async function main() {
    // 1. 设置客户端
    const privateKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';
    if (!privateKey) {
        throw new Error('Please set PRIVATE_KEY in environment variables');
    }
    const account = privateKeyToAccount(`${privateKey}`);

    const rpc = 'http://127.0.0.1:8545/';//npx hardhat node

    
    const walletClient = createWalletClient({
        account,
        chain: hardhat,
        transport: http(rpc)
    });
    
    const publicClient = createPublicClient({
        chain: hardhat,
        transport: http(rpc)
    });
    
    // 2. 读取合约ABI和字节码
    const artifactPath = path.join('./artifacts/contracts/Storage.sol/', 'Storage.json');
    const contractArtifact = JSON.parse(fs.readFileSync(artifactPath, 'utf-8'));
    
    // 3. 部署合约
    console.log('Deploying contract...');
    const hash = await walletClient.deployContract({
        abi: contractArtifact.abi,
        bytecode: contractArtifact.bytecode ,
        args:[]
    });
    
    const receipt = await publicClient.waitForTransactionReceipt({ hash });
    if (!receipt.contractAddress) {
        throw new Error('Contract deployment failed');
    }
    const contractAddress = receipt.contractAddress;
    console.log('Contract deployed to:', contractAddress);
    
    // 4. 与合约交互
    const contract = {
        address: contractAddress,
        abi: contractArtifact.abi
    };
    
    // 存储值
    console.log('Storing value 42...');
    const storeHash = await walletClient.writeContract({
        ...contract,
        functionName: 'store',
        args: [42],
    });
    await publicClient.waitForTransactionReceipt({ hash: storeHash });
    console.log('Value stored');
    
    // 读取值
    const value = await publicClient.readContract({
        ...contract,
        functionName: 'retrieve',
        args: [],
    });
    console.log('Retrieved value:', value);
    
    // 5. 监听事件
    const unwatch = publicClient.watchContractEvent({
        ...contract,
        eventName: 'ValueChanged',
        onLogs: (logs) => {
            logs.forEach((log) => {
                console.log('Event ValueChanged:', log.data?.toString());
                unwatch();
            });
        }
    });
    
    // 再次存储以触发事件
    console.log('Storing value 100...');
    const storeHash2 = await walletClient.writeContract({
        ...contract,
        functionName: 'store',
        args: [100],
    });
    await publicClient.waitForTransactionReceipt({ hash: storeHash2 });
    
    // 等待一段时间让事件被处理
    await new Promise(resolve => setTimeout(resolve, 5000));
    
    // 停止监听
    unwatch();
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});