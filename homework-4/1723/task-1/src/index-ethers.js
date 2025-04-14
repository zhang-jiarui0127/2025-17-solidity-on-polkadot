// 引入 ethers.js 库
const { ethers } = require("ethers");
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
async function deployContract(wallet) {
    // 创建合约工厂
    const StorageFactory = new ethers.ContractFactory(abi, bytecode, wallet);
    console.log("部署合约...");
    const storageContract = await StorageFactory.deploy();
    // 等待合约部署完成
    await storageContract.waitForDeployment();
    // 获取合约地址
    const contractAddress = await storageContract.getAddress();
    console.log("合约已部署，地址为：", contractAddress);
    return storageContract;
}

// 调用合约函数
async function callContract(contract) {
    // 生成一个随机数
    const randomNumber = Math.floor(Math.random() * 100);
    console.log("调用 store 函数，传入随机数：", randomNumber);
    // 调用 store 函数
    const tx = await contract.store(randomNumber, {
        gasLimit: 300000,
    });
    console.log("等待交易确认...");
    await tx.wait();
    console.log("store 函数调用成功");
}

// 监听事件函数
async function listenToEvents(contract) {
    isListening = true;
    console.log("开始监听 SomeThing 事件");
    const filter = contract.filters.SomeThing();
    console.log("过滤器已成功创建");
    // 监听 SomeThing 事件
    contract.on(filter, (params) => {
        console.log("SomeThing 事件触发:", params.args);
        // 如果 newNumber 大于 50，关闭监听
        if (params.args[1] > 50) {
            console.log("newNumber 大于 50，关闭监听");
            contract.off(filter);
            // 结束脚本运行
            process.exit(0);
        }
        // 设置10分钟后自动退出
        setTimeout(() => {
            console.log("监听超时，自动退出");
            contract.off(filter);
            // 结束脚本运行
            process.exit(0);
        }, 10 * 60 * 1000);
    });
    console.log("监听 SomeThing 事件成功");
}

// 主函数
async function main() {
    // 配置网络
    const provider = new ethers.JsonRpcProvider(SEPOLIA_RPC_URL);
    const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
    console.log("钱包地址：", wallet.address);

    // 钱包余额
    const balance = await provider.getBalance(wallet.address);
    console.log("钱包余额：", ethers.formatEther(balance));

    // 部署合约
    const contract = await deployContract(wallet);
    
    // 监听事件
    await listenToEvents(contract);
    
    // 调用合约
    callContract(contract)
    // 循环调用直到关闭监听
    loopId = setInterval(async () => {
        if (!isListening) return;
        await callContract(contract);
    }, 60 * 1000);
}

// 执行主函数
main().catch((error) => {
    console.error("执行出错：", error);
});