import { createPublicClient, createWalletClient, defineChain, getContract, hexToBigInt, http } from "viem"
import { privateKeyToAccount } from "viem/accounts"
import { ABI, BYTECODE } from "./trc20"

export const localChain = (url: string) => defineChain({
    id: 31337,
    name: 'Testnet',
    network: 'Testnet',
    nativeCurrency: {
        name: 'ETH',
        symbol: 'ETH',
        decimals: 18
    },
    rpcUrls: {
        default: {
            http: [url],
        }
    },
    testnet: true,
})

async function main() {
    const url = "http://127.0.0.1:8545"
    const publicClient = createPublicClient({chain: localChain(url), transport: http()}) 
    const blockNumber = await publicClient.getBlockNumber()
    const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    const wallet = privateKeyToAccount(privateKey)
    const walletAddress = wallet.address
    const balance = publicClient.getBalance({ address: walletAddress})

    const walletClient = createWalletClient({ account: wallet, chain: localChain(url), transport: http()})
    const tx = await walletClient.sendTransaction({
        to: '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
        value: hexToBigInt("0x1000"),
    })

    // const tx2 = await walletClient.deployContract({
    //     abi: ABI,
    //     bytecode: BYTECODE,
    //     args: ["name", "symbol", 18, 100000000]
    // })
    // const receipt = await publicClient.waitForTransactionReceipt({ hash: tx2 })
    // const contractAddress = receipt.contractAddress

    // if (typeof contractAddress != "string" || !contractAddress.startsWith("0x")) {
    //     throw new Error(`Invalid contract address: ${contractAddress}`)
    // }
    // const totalSupply = await publicClient.readContract({
    //     address: contractAddress,
    //     abi: ABI,
    //     functionName: 'totalSupply',
    // })

    // const writeContract = getContract({address: contractAddress, abi: ABI, client:walletClient})
    // const transferTx = await writeContract.write.transfer([
    //     "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
    //     123
    // ])

    // const trc20Balance = await publicClient.readContract({
    //     address: contractAddress,
    //     abi: ABI,
    //     functionName: 'balanceOf',
    //     args: ["0x70997970C51812dc3A010C7d01b50e0d17dc79C8"]
    // })

    // console.log(`result is ${trc20Balance}`)

    // publicClient.watchBlockNumber({
    //     onBlockNumber(blockNumber) {
    //         console.log(`block number is ${blockNumber}`)
    //     }
    // })  

}


main()
