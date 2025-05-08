import { createPublicClient, http, createWalletClient, parseAbi } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { localhost } from "viem/chains";
import { readFileSync } from "fs";

async function main() {
    // 配置客户端
    const publicClient = createPublicClient({
        chain: localhost,
        transport: http("http://127.0.0.1:8545"),
    });
    const walletClient = createWalletClient({
        chain: localhost,
        transport: http("http://127.0.0.1:8545"),
        account: privateKeyToAccount("0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"),
    });

    // 读取编译后的合约 ABI 和字节码
    const artifact = JSON.parse(readFileSync("./artifacts/contracts/1581-Storage.sol/Storage.json", "utf8"));
    const abi = artifact.abi;
    const bytecode = artifact.bytecode;

    // 部署合约
    const hash = await walletClient.deployContract({
        abi,
        bytecode,
        args: [],
    });
    const receipt = await publicClient.waitForTransactionReceipt({ hash });
    const contractAddress = receipt.contractAddress!;
    console.log("Storage deployed to:", contractAddress);

    // 调用 store 函数
    await walletClient.writeContract({
        address: contractAddress,
        abi,
        functionName: "store",
        args: [42],
    });
    console.log("Stored 42");

    // 查询 retrieve 函数
    const number = await publicClient.readContract({
        address: contractAddress,
        abi,
        functionName: "retrieve",
    });
    console.log("Retrieved number:", number);

    // 监听 NumberUpdated 事件
    publicClient.watchContractEvent({
        address: contractAddress,
        abi,
        eventName: "NumberUpdated",
        onLogs: (logs) => {
            console.log("Event NumberUpdated:", logs[0].args.newNumber);
        },
    });

    // 再次调用 store 触发事件
    await walletClient.writeContract({
        address: contractAddress,
        abi,
        functionName: "store",
        args: [100],
    });
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});