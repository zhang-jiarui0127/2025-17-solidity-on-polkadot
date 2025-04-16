import { ABI, BYTECODE } from "./contractData"
import { createPublicClient, createWalletClient, defineChain, http, getContract } from "viem"
import { privateKeyToAccount } from "viem/accounts"

export const localChain = (url: string) => defineChain({
    id: 31337,
    name: 'Testnet',
    network: 'Testnet',
    nativeCurrency: {
        name: 'ETH',
        symbol: 'ETH',
        decimals: 18,
    },
    rpcUrls: {
        default: {
            http: [url],
        },
        public: {
            http: [url],
        },
    },
    testnet: true,
})

async function main() {
    try {
        const url = "http://127.0.0.1:8545"
        const publicClient = createPublicClient({ chain: localChain(url), transport: http() })
        const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
        const wallet = privateKeyToAccount(privateKey)
        const address = wallet.address
        console.log("钱包地址:", address)

        // 检查余额
        const balance = await publicClient.getBalance({ address: address })
        console.log("账户余额:", balance.toString())

        // 创建钱包客户端
        const walletClient = createWalletClient({
            account: wallet,
            chain: localChain(url),
            transport: http()
        })

        // 部署合约
        console.log("正在部署合约...")
        const contract = await walletClient.deployContract({
            abi: ABI,
            bytecode: `0x${BYTECODE}` as `0x${string}`,
            args: []  // Storage 合约不需要构造函数参数
        })

        const receipt = await publicClient.waitForTransactionReceipt({ hash: contract })
        const contractAddress = receipt.contractAddress
        if (!contractAddress) {
            throw new Error("合约部署失败")
        }
        console.log("合约已部署到地址:", contractAddress)

        // 创建合约实例
        const deployedContract = getContract({
            address: contractAddress,
            abi: ABI,
            publicClient,
            walletClient,
        })

        // 调用 store 方法
        console.log("正在调用 store 方法...")
        const hash = await deployedContract.write.store([100n])
        const storeReceipt = await publicClient.waitForTransactionReceipt({ hash })
        console.log("store 方法调用成功，交易哈希:", storeReceipt.transactionHash)

        // 读取值
        const value = await publicClient.readContract({
            address: contractAddress,
            abi: ABI,
            functionName: "retrieve"
        }) as bigint
        console.log("存储的值:", value.toString())

        // 监听区块
        publicClient.watchBlockNumber({
            onBlockNumber: (blockNumber) => {
                console.log(`当前区块: ${blockNumber}`)
            },
            onError: (error) => {
                console.error(`监听错误: ${error}`)
            }
        })

    } catch (error) {
        console.error("发生错误:", error)
    }
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error)
        process.exit(1)
    })