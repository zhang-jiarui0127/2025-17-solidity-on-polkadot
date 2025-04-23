import { createPublicClient, createWalletClient, http, getContract, Hex } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { ABI, BYTECODE } from "./storage";
import { localChain } from "./wallet";

async function main() {
    const url = "http://127.0.0.1:8545";
    const publicClient = createPublicClient({ 
        chain: localChain, 
        transport: http() 
    });

    // 修改私钥处理
    const privateKey = process.env.PRIVATE_KEY;
    if (!privateKey) {
        throw new Error("Private key not found in environment variables");
    }
    // 确保私钥格式正确并转换为 Hex 类型
    const formattedPrivateKey = (privateKey.startsWith('0x') ? privateKey : `0x${privateKey}`) as Hex;
    const account = privateKeyToAccount(formattedPrivateKey);

    const walletClient = createWalletClient({ 
        account, 
        chain: localChain, 
        transport: http() 
    });

    console.log("开始部署Storage合约...");

    // 确保字节码格式正确并转换为 Hex 类型
    const formattedBytecode = (BYTECODE.startsWith('0x') ? BYTECODE : `0x${BYTECODE}`) as Hex;
    
    // 部署合约
    const hash = await walletClient.deployContract({
        abi: ABI,
        bytecode: formattedBytecode,
        args: []
    });

    // 等待部署完成并获取合约地址
    const receipt = await publicClient.waitForTransactionReceipt({ hash });
    const contractAddress = receipt.contractAddress;
    if (typeof contractAddress !== 'string' || !contractAddress.startsWith('0x')) {
        throw new Error(`Invalid contract address: ${contractAddress}`);
    }
    console.log("Storage合约已部署到地址:", contractAddress);

    // 测试合约功能
    console.log("测试合约功能...");

    // 存储数值
    const storeValue = 42;
    const deployedContract = getContract({
        address: contractAddress,
        abi: ABI,
        client: walletClient
    });

    const tx = await deployedContract.write.store([storeValue]);
    await publicClient.waitForTransactionReceipt({ hash: tx });
    console.log(`已存储数值: ${storeValue}`);

    // 读取数值
    const value = await publicClient.readContract({
        address: contractAddress,
        abi: ABI,
        functionName: "retrieve",
        args: []
    });
    console.log(`读取到的数值: ${value}`);

    // 监听新区块
    const unwatch = publicClient.watchBlockNumber({
        onBlockNumber: (blockNumber) => {
            console.log(`当前区块: ${blockNumber}`);
        },
        onError: (error) => {
            console.error(`错误: ${error}`);
        }
    });

    // 5秒后停止监听
    setTimeout(() => {
        unwatch();
    }, 5000);
}

main().catch((error) => {
    console.error("部署过程中发生错误:", error);
    process.exit(1);
});