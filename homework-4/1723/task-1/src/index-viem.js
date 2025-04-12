// 引入 viem 库
const { createWalletClient, createPublicClient, http, parseEther, formatEther } = require("viem");
const { privateKeyToAccount } = require("viem/accounts");
const { sepolia } = require("viem/chains");
// Storage 合约的 ABI 和字节码
const { abi, bytecode } = require("./Storage.json");

// 配置网络和钱包
const SEPOLIA_RPC_URL = "your sepolia rpc url";
const PRIVATE_KEY = "your private key";
// 是否在监听
let isListening = false;
// 循环监听id
let loopId = null;

// 部署合约函数
async function deployContract(publicClient, walletClient, account) {
    console.log("部署合约...");
    
    // 部署合约
    const hash = await walletClient.deployContract({
        abi,
        bytecode,
        account,
    });
    
    console.log("交易哈希:", hash);
    
    // 等待交易确认
    const receipt = await publicClient.waitForTransactionReceipt({ hash });
    const contractAddress = receipt.contractAddress;
    
    console.log("合约已部署，地址为：", contractAddress);
    return contractAddress;
}

// 调用合约函数
async function callContract(publicClient, walletClient, account, contractAddress) {
    // 生成一个随机数
    const randomNumber = Math.floor(Math.random() * 100);
    console.log("调用 store 函数，传入随机数：", randomNumber);
    
    // 调用 store 函数
    const hash = await walletClient.writeContract({
        address: contractAddress,
        abi,
        functionName: 'store',
        args: [randomNumber],
        account,
        gas: 300000n,
    });
    
    console.log("等待交易确认...");
    await publicClient.waitForTransactionReceipt({ hash });
    console.log("store 函数调用成功");
}

// 监听事件函数
async function listenToEvents(publicClient, contractAddress) {
    isListening = true;
    console.log("开始监听 SomeThing 事件");
    
    // 创建事件监听
    const unwatch = publicClient.watchContractEvent({
        address: contractAddress,
        abi,
        eventName: 'SomeThing',
        onLogs: (logs) => {
            for (const log of logs) {
                console.log("SomeThing 事件触发:", log.args);
                
                // 如果 newNumber 大于 50，关闭监听
                if (log.args[1] > 50) {
                    console.log("newNumber 大于 50，关闭监听");
                    unwatch();
                    isListening = false;
                    
                    // 清除循环调用
                    if (loopId) {
                        clearInterval(loopId);
                    }
                    
                    // 结束脚本运行
                    process.exit(0);
                }
            }
        }
    });
    
    console.log("监听 SomeThing 事件成功");
    
    // 设置10分钟后自动退出
    setTimeout(() => {
        console.log("监听超时，自动退出");
        unwatch();
        isListening = false;
        
        // 清除循环调用
        if (loopId) {
            clearInterval(loopId);
        }
        
        // 结束脚本运行
        process.exit(0);
    }, 10 * 60 * 1000);
}

// 主函数
async function main() {
    // 创建账户
    const account = privateKeyToAccount(`0x${PRIVATE_KEY}`);
    console.log("钱包地址：", account.address);
    
    // 创建钱包客户端
    const walletClient = createWalletClient({
        account,
        chain: sepolia,
        transport: http(SEPOLIA_RPC_URL),
    });
    
    // 创建公共客户端
    const publicClient = createPublicClient({
        chain: sepolia,
        transport: http(SEPOLIA_RPC_URL),
    });
    
    // 获取钱包余额
    const balance = await publicClient.getBalance({
        address: account.address,
    });
    console.log("钱包余额：", formatEther(balance));
    
    // 部署合约
    const contractAddress = await deployContract(publicClient, walletClient, account);
    
    // 监听事件
    await listenToEvents(publicClient, contractAddress);
    
    // 调用合约
    await callContract(publicClient, walletClient, account, contractAddress);
    
    // 循环调用直到关闭监听
    loopId = setInterval(async () => {
        if (!isListening) return;
        await callContract(publicClient, walletClient, account, contractAddress);
    }, 60 * 1000);
}

// 执行主函数
main().catch((error) => {
    console.error("执行出错：", error);
});