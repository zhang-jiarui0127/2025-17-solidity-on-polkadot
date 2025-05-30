// ethers-example.js
import { ethers } from "ethers";

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
// 1. 连接到Sepolia测试网
const provider = new ethers.JsonRpcProvider("https://rpc.sepolia.dev");
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY || "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80", provider);
console.log("钱包地址:", wallet.address);

// 2. 部署合约
const factory = new ethers.ContractFactory(contractData.abi, contractData.bytecode, wallet);
const contract = await factory.deploy();
await contract.waitForDeployment();
const address = await contract.getAddress();
console.log("合约部署地址:", address);
console.log(`浏览器查看: https://sepolia.etherscan.io/address/${address}`);

// 3. 调用store方法
console.log("正在设置number为42...");
const tx = await contract.store(42);
await tx.wait();
console.log("交易完成:", tx.hash);

// 4. 调用retrieve方法
const currentNumber = await contract.retrieve();
console.log("当前number值:", currentNumber.toString());

// 5. 监听事件
contract.on("NumberSet", (oldNumber, newNumber, event) => {
console.log("\n=== 事件触发 ===");
console.log("事件:", event.eventName);
console.log("旧值:", oldNumber.toString());
console.log("新值:", newNumber.toString());
console.log("区块:", event.blockNumber);
console.log("交易:", event.transactionHash);
});

// 6. 再次调用store方法触发事件
console.log("\n5秒后将设置新值100...");
setTimeout(async () => {
console.log("正在设置number为100...");
const tx2 = await contract.store(100);
await tx2.wait();
console.log("交易完成:", tx2.hash);

// 7. 读取新值
const updatedNumber = await contract.retrieve();
console.log("更新后的number值:", updatedNumber.toString());

// 8. 10秒后停止监听
setTimeout(() => {
contract.removeAllListeners();
console.log("\n已停止事件监听");
process.exit(0);
}, 10000);
}, 5000);
}

main().catch(console.error);