import { createPublicClient, createWalletClient, defineChain, http, hexToBigInt, getContract } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { ABI, BYTECODE } from "../abi/storage";
import { ethers } from "ethers";

import config from '../config';

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

function toViemAddress(address: string): string {
    return address.startsWith("0x") ? address : `0x${address}`
}

export function getViemClient(url: string) {
    return createPublicClient({
        chain: localChain(url),
        transport: http(url),
    })
}

export function remove0x(privateKey: string): string {
    return privateKey.startsWith('0x') ? privateKey.slice(2) : privateKey;
}

const privateKey = remove0x(config.privateKey);
console.log("privateKey: ", privateKey);

const walletClient = createWalletClient({
    chain: localChain(config.localRpcUrl),
    transport: http(config.localRpcUrl),
    account: privateKeyToAccount(config.privateKey as `0x${string}`),
})

export async function deployContract(): Promise<string> {


    const hash = await walletClient.deployContract({
        abi: ABI,
        bytecode: `0x${BYTECODE}`,
        args: []
    })

    const publicClient = getViemClient(config.localRpcUrl)
    const receipt = await publicClient.waitForTransactionReceipt({ hash })

    if (!receipt.contractAddress) {
        throw new Error('Contract deployment failed: no contract address in receipt')
    }

    return receipt.contractAddress
}

async function main() {
    const client = getViemClient(config.localRpcUrl);

    const accountAddress = toViemAddress(privateKeyToAccount(config.privateKey).address) as `0x${string}`
    const balance = await client.getBalance({
        address: accountAddress,
    })
    console.log("Account Balance:", ethers.formatEther(balance), "ETH");

    const blockNumber = await client.getBlockNumber()
    console.log("Block Number:", blockNumber);

    const nonce = await client.getTransactionCount({ address: accountAddress })
    console.log("Nonce:", nonce);

    // const txHash = await walletClient.sendTransaction({ to: config.accountAddress2, value: hexToBigInt('0x10000') })
    const txHash = await walletClient.sendTransaction({ to: config.accountAddress2, value: BigInt(10_000_000_000_000_000) })
    console.log("Transaction Hash:", txHash);

    const txReceipt = await client.waitForTransactionReceipt({ hash: txHash })
    console.log("Transaction Receipt:", txReceipt);

    const balanceAfter = await client.getBalance({ address: accountAddress })
    console.log("Account Balance After:", ethers.formatEther(balanceAfter), "ETH");

    const balance2 = await client.getBalance({ address: config.accountAddress2 })
    console.log("Account Balance2:", ethers.formatEther(balance2), "ETH");

    const contractAddress = await deployContract() as `0x${string}`
    console.log("Contract Address:", contractAddress);

    const retrieve = await client.readContract({
        address: contractAddress,
        abi: ABI,
        functionName: 'retrieve',
        args: [],
    }) as bigint
    console.log("Retrieved Value:", retrieve.toString());

    const deployedContract = getContract({ address: contractAddress, abi: ABI, client: walletClient })

    const storeTx = await deployedContract.write.store([10000])
    console.log("Store Transaction Hash:", storeTx);

    const receipt = await client.waitForTransactionReceipt({ hash: storeTx })
    console.log("Store Transaction Receipt:", receipt);

    const newRetrieve = await client.readContract({
        address: contractAddress,
        abi: ABI,
        functionName: 'retrieve',
        args: [],
    }) as bigint
    console.log("Retrieved Value:", newRetrieve.toString());

    client.watchBlockNumber({
        onBlockNumber: (blockNumber) => {
            console.log(`block is ${blockNumber}`)
        },
        onError: (error) => {
            console.error(`error is ${error}`)
        }
    })
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
