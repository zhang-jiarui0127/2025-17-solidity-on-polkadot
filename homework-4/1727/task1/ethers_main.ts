import { Contract, ethers, Wallet } from "ethers" // 导入 ethers 库中的 Contract、ethers 和 Wallet
import { ABI, BYTECODE } from "./erc20" // 导入 ERC20 合约的 ABI 和 BYTECODE

async function main() {
    const url = "http://127.0.0.1:8545" // 本地以太坊节点的 RPC URL
    const provider = new ethers.JsonRpcProvider(url) // 创建一个以太坊提供者实例，用于与区块链交互
    const block = await provider.getBlockNumber() // 获取当前区块号
    const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" // 测试账户的私钥
    const wallet = new Wallet(privateKey, provider) // 使用私钥和提供者创建钱包实例
    const address = wallet.address // 获取钱包地址
    const balance = await provider.getBalance(address) // 查询钱包余额
    const ethValue = ethers.formatEther(balance) // 将余额从 Wei 转换为 ETH
    const nonce = await provider.getTransactionCount(address) // 获取当前账户的交易计数（nonce）

    // 准备转账交易对象
    const transfer = {
        to: "0x90F79bf6EB2c4f870365E785982E1f101E93b906", // 接收地址
        value: "1000000000" // 转账金额（Wei）
    }
    
    // 发送转账交易
    const tx = await wallet.sendTransaction(transfer) // 发送交易
    await tx.wait() // 等待交易被打包到区块中

    // 创建合约工厂实例
    const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet) // 使用 ABI 和 BYTECODE 创建合约工厂
    const contract = await factory.deploy(1000000000000) // 部署合约，传入初始供应量
    await contract.waitForDeployment() // 等待合约部署完成
    const contractAddress = contract.target.toString() // 获取部署后的合约地址

    // 创建合约实例
    const deployedContract = new Contract(contractAddress, ABI, provider) // 使用合约地址和 ABI 创建合约实例
    const totalSupply = await deployedContract.totalSupply() // 查询合约的总供应量

    // 创建带有钱包的合约实例
    const walletContract = new Contract(contractAddress, ABI, wallet) // 使用钱包创建合约实例
    const tx2 = await walletContract.transfer("0x90F79bf6EB2c4f870365E785982E1f101E93b906", 1) // 调用合约的 transfer 方法进行转账
    await tx2.wait() // 等待转账交易被打包

    // 查询接收地址的 ERC20 代币余额
    const erc20Balance = await deployedContract.balanceOf("0x90F79bf6EB2c4f870365E785982E1f101E93b906") // 查询余额
    console.log(erc20Balance) // 打印余额

    // 监听新区块事件
    provider.on("block", (blockNumber) => {
        console.log(`current block ${blockNumber}`) // 打印当前区块号
        if (blockNumber > 55) { // 如果区块号大于 55
            provider.off("block") // 取消监听
        }
    })

    // 获取转账交易的收据
    const receipt = await provider.getTransactionReceipt(tx2.hash) // 获取交易收据
    const data = receipt?.fee ? ethers.formatEther(receipt.fee) : "0" // 获取交易费用并转换为 ETH

    console.log(`result is ${data} `) // 打印交易费用
}

// 执行主函数
main()