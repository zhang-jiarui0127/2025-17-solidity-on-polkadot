import { createPublicClient, createWalletClient, defineChain, getContract, http } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { ABI, BYTECODE } from "./Storage"; // 确保 ABI 和 BYTECODE 正确导入

// 定义本地链配置
const localChain = defineChain({
    id: 31337,
    name: "Localhost",
    network: "localhost",
    nativeCurrency: {
        name: "Ether",
        symbol: "ETH",
        decimals: 18,
    },
    rpcUrls: {
        default: {
            http: ["http://127.0.0.1:8545"],
        },
    },
    testnet: true,
});

const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"

// 创建账户和客户端
const account = privateKeyToAccount(privateKey);
const publicClient = createPublicClient({
    chain: localChain,
    transport: http(),
});
const walletClient = createWalletClient({
    account,
    chain: localChain,
    transport: http(),
});

async function main() {
    // 部署合约
    const hash = await walletClient.deployContract({
        abi: ABI,
        bytecode: BYTECODE,
    });
    const receipt = await publicClient.waitForTransactionReceipt({ hash });
    const address = receipt.contractAddress!;
    console.log(" Storage 合约已部署，地址：", address);

    // 创建合约实例
    const contract = getContract({
        address,
        abi: ABI,
        client: publicClient,
    });

    // 监听 DataChanged 事件
    publicClient.watchContractEvent({
        address,
        abi: ABI,
        eventName: "DataChanged",
        onLogs: (logs) => {
            logs.forEach((log) => {
                console.log(" 监听到事件 DataChanged, 值：", log.data.toString());
            });
        },
    });

    // 调用 set 方法设置值为 42
    const { request } = await publicClient.simulateContract({
        address,
        abi: ABI,
        functionName: "set",
        args: [42n],
        account,
    });
    const txHash = await walletClient.writeContract(request);
    await publicClient.waitForTransactionReceipt({ hash: txHash });
    console.log(" 已调用 set(42)");

    // 调用 get 方法获取当前存储的值
    const stored = await publicClient.readContract({
        address,
        abi: ABI,
        functionName: "get",
    });
    console.log(" 当前存储的值：", stored);
}

main().catch((err) => {
    console.error(" 执行出错：", err);
    process.exit(1);
});
