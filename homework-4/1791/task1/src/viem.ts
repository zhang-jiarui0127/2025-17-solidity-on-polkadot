import { ABI, BYTECODE } from "./erc20"
import { createPublicClient, createWalletClient, defineChain, hexToBigInt, http, getContract } from "viem"
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
    },
    testnet: true,
})

async function viem_main() {
    const url = "http://127.0.0.1:8545"
    const publicClient = createPublicClient({chain: localChain(url), transport: http()})
    const blockNumber = await publicClient.getBlockNumber()
    console.log(`blockNumber is ${blockNumber}`)

    const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    const wallet = privateKeyToAccount(privateKey)
    const walletAddress = wallet.address
    console.log(`walletAddress is ${walletAddress}`)

    const balance = publicClient.getBalance({address: walletAddress})
    console.log(`balance is ${balance}`)

    const walletClient = createWalletClient({account: wallet, chain: localChain(url), transport: http()})
    const tx = await walletClient.sendTransaction({
        to: "0x90F79bf6EB2c4f870365E785982E1f101E93b906",
        value: hexToBigInt("0x1000")
    })
    console.log(`tx is ${tx}`)


    const tx2 = await walletClient.deployContract({
        abi: ABI,
        bytecode: BYTECODE,
        args: ["name", "symbol", 18, 10002211]
    })
    console.log(`tx2 is ${tx2}`)

    const receipt = await publicClient.waitForTransactionReceipt({hash: tx2})
    const contractAddress = receipt.contractAddress
    console.log(`contractAddress is ${contractAddress}`)

    if (typeof contractAddress !== 'string' || !contractAddress.startsWith('0x')) {
        throw new Error(`invalid contract address: ${contractAddress}`)
    }

    const totalSupply = await publicClient.readContract({address : contractAddress, abi: ABI, functionName: "totalSupply"})
    const writeContract = getContract({address: contractAddress, abi: ABI, client: walletClient})
    const transferTx = await writeContract.write.transfer(["0x90F79bf6EB2c4f870365E785982E1f101E93b906", 456])

    const erc20Balance = await publicClient.readContract({
        address: contractAddress, abi: ABI, functionName: "balanceOf", args: ["0x90F79bf6EB2c4f870365E785982E1f101E93b906"]
    })

    console.log(`erc20Balance is ${erc20Balance}`)
    
    // listen
    // publicClient.watchBlockNumber({
    //     onBlockNumber: (blockNumber) => {
    //         console.log(`listen block number is ${blockNumber}`)
    //     }        
    // })
}

viem_main()