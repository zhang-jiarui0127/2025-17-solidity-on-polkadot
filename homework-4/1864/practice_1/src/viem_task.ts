import { ABI, BYTECODE } from "./storage"
import { createPublicClient, createWalletClient, defineChain, hexToBigInt, http, getContract } from "viem"
import { privateKeyToAccount } from "viem/accounts"
import { config } from "./config";

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
    },  
    testnet: true,
})

async function main() {
    const publicClient = createPublicClient({ chain: localChain(config.rpcUrl), transport: http() })
    const blockNumber = await publicClient.getBlockNumber()
    console.log("blockNumber is :", blockNumber)
    const wallet = privateKeyToAccount(config.privateKey as `0x${string}`)
    const walletAddress = wallet.address
    const balance = await publicClient.getBalance({ address: walletAddress })
    console.log("balance is :", balance)
    const nonce = await publicClient.getTransactionCount({ address: walletAddress })
    console.log("nonce is :", nonce)
    const walletClient = createWalletClient({ account: wallet, chain: localChain(config.rpcUrl), transport: http() })
    const txHash = await walletClient.sendTransaction({ to: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", value: hexToBigInt('0x10000') })
    console.log("txHash is :", txHash)

    const tx2 = await walletClient.deployContract({
        abi: ABI,
        bytecode: BYTECODE,
    })
    console.log("tx2 is :", tx2)

    // 取得reciept
    const receipt = await publicClient.waitForTransactionReceipt({hash : tx2})
    const contractAddress = receipt.contractAddress
    console.log("Contract deployed at:", contractAddress)

    // 添加合约事件监听
    const unwatch = publicClient.watchEvent({
        address: contractAddress as `0x${string}`,
        event: {
            name: 'NumberChanged',
            type: 'event',
            inputs: [
                { type: 'uint256', name: 'oldValue', indexed: false },
                { type: 'uint256', name: 'newValue', indexed: false }
            ]
        },
        onLogs: (logs) => {
            console.log('NumberChanged event detected:', logs)
            // 打印事件的详细信息
            logs.forEach(log => {
                console.log('Event details:', {
                    oldValue: log.args.oldValue?.toString(),
                    newValue: log.args.newValue?.toString(),
                    transactionHash: log.transactionHash,
                    blockNumber: log.blockNumber
                })
            })
        },
    })

    // 取得 writeContract
    const writeContract = getContract({address:contractAddress as `0x${string}`, abi:ABI, client:walletClient})

    // 调用 store 函数
    const storeTx = await writeContract.write.store([21])
    console.log("store transaction hash:", storeTx)

    // 等待交易确认
    await publicClient.waitForTransactionReceipt({hash: storeTx})
    console.log("store transaction confirmed")

    // 调用 retrieve 函数并处理返回值
    const value = await publicClient.readContract({
        address: contractAddress as `0x${string}`,
        abi: ABI,
        functionName: 'retrieve',
        account: walletAddress,
    }) as bigint
    console.log("retrieved value:", value.toString())

    // 在程序结束时取消监听
    process.on('SIGINT', () => {
        unwatch()
        process.exit()
    })
}

main()