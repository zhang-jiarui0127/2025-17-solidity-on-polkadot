import { ABI, BYTECODE } from "./erc20"
import { createPublicClient, createWalletClient, defineChain, hexToBigInt, http, getContract } from "viem"
import { privateKeyToAccount } from "viem/accounts"

/**
 * 定义本地测试链的配置
 * @param url - RPC节点的URL地址
 * @returns 返回一个配置好的本地链对象
 */
export const localChain = (url: string) => defineChain({
    id: 31337,                    // 链ID
    name: 'Testnet',              // 链名称
    network: 'Testnet',           // 网络名称
    nativeCurrency: {             // 原生代币配置
        name: 'ETH',              // 代币名称
        symbol: 'ETH',            // 代币符号
        decimals: 18,             // 代币精度
    },
    rpcUrls: {                    // RPC节点配置
        default: {
            http: [url],          // HTTP RPC地址
        },
    },
    testnet: true,                // 标记为测试网
})

/**
 * 将地址转换为viem格式的地址（确保以0x开头）
 * @param address - 需要转换的地址
 * @returns 返回标准格式的地址
 */
function toViemAddress(address: string): string {
    return address.startsWith("0x") ? address : `0x${address}`
}

/**
 * 主函数，包含所有区块链交互操作
 */
async function main() {
    // 设置本地节点URL
    const url = "http://127.0.0.1:8545"
    
    // 创建公共客户端，用于读取链上数据
    const publicClient = createPublicClient({ chain: localChain(url), transport: http() })
    
    // 获取当前区块号
    const blockNumber = await publicClient.getBlockNumber()
    
    // 设置测试账户的私钥（仅用于测试环境）
    const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    
    // 从私钥创建账户
    const wallet = privateKeyToAccount(privateKey)
    const address = wallet.address
    
    // 获取账户余额
    const balance = await publicClient.getBalance({ address: address })
    
    // 获取账户交易计数（nonce）
    const nonce = await publicClient.getTransactionCount({ address: address })

    // 创建钱包客户端，用于发送交易
    const walletClient = createWalletClient({ account: wallet, chain: localChain(url), transport: http() })
    
    // 发送ETH转账交易
    const txHash = await walletClient.sendTransaction({ 
        to: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", 
        value: hexToBigInt('0x10000') 
    })
    console.log("发送ETH转账交易:", txHash);
    // 部署ERC20合约
    console.log("开始部署合约...");
    console.log("初始供应量:", 1000000000000);
    const contract = await walletClient.deployContract({
        abi: ABI,                 // 合约ABI
        bytecode: BYTECODE,       // 合约字节码
        args: [1000000000000]     // 构造函数参数：初始供应量
    });
    console.log("合约部署交易哈希:", contract);

    // 等待合约部署交易确认
    console.log("等待交易确认...");
    const receipt = await publicClient.waitForTransactionReceipt({ hash: contract });
    console.log("交易已确认，区块号:", receipt.blockNumber);
    const contractAddress = receipt.contractAddress;
    console.log("合约地址:", contractAddress);

    // 验证合约地址格式
    if (typeof contractAddress !== 'string' || !contractAddress.startsWith('0x')) {
        throw new Error(`Invalid contract address: ${contractAddress}`);
    }

    // 读取合约的总供应量
    const totalSupply = await publicClient.readContract({ 
        address: contractAddress, 
        abi: ABI, 
        functionName: "totalSupply", 
        args: [] 
    })
    console.log("totalSupply:", totalSupply);
    // 获取已部署合约的实例
    const deployedContract = getContract({ 
        address: contractAddress, 
        abi: ABI, 
        client: walletClient 
    })
    
    // 调用合约的transfer方法转账
    const tx2 = await deployedContract.write.transfer([
        "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", 
        10000
    ])
    console.log("transfer:", tx2);
    // 查询目标地址的ERC20代币余额
    const erc20Balance = await publicClient.readContract({ 
        address: contractAddress, 
        abi: ABI, 
        functionName: "balanceOf", 
        args: ["0x70997970C51812dc3A010C7d01b50e0d17dc79C8"] 
    })
    console.log("erc20Balance:", erc20Balance);
    // 打印余额结果
    console.log(`result is ${erc20Balance}`)

    // 监听新区块
    publicClient.watchBlockNumber({
        onBlockNumber: (blockNumber) => {
            console.log(`block is ${blockNumber}`)
        },
        onError: (error) => {
            console.error(`error is ${error}`)
        }
    })
}

// 执行主函数
main()