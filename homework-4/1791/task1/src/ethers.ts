import {ethers, Wallet, Contract } from "ethers"
import { ABI, BYTECODE} from "./erc20"

async function ethers_main() {
    // anvil
    const url = "http://127.0.0.1:8545"
    const provider = new ethers.JsonRpcProvider(url)
    const blockNumber = await provider.getBlockNumber()
    console.log(`blockNumber is ${blockNumber}`)

    const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    const wallet = new Wallet(privateKey, provider)
    const walletAddress = wallet.address
    console.log(`walletAddress is ${walletAddress}`)

    const balance = await provider.getBalance(walletAddress)
    console.log(`balance is ${balance}`)
    const nonce = await provider.getTransactionCount(walletAddress)   
    console.log(`nonce is ${nonce}`)

    const transfer = {
        to: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
        value : "10001111"
    }

    const tx = await wallet.sendTransaction(transfer)
    await tx.wait()
    const hash = tx.hash
    console.log(`hash is ${hash}`)

    const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet)
    const contract = await factory.deploy("name", "symbol", 18, 10002222)
    await contract.waitForDeployment()
    const contractAddress = contract.target.toString()

    console.log(`contractAddress is ${contractAddress}`)

    const readContract = new Contract(contractAddress, ABI, provider)
    const totalSupply = await readContract.totalSupply()
    
    console.log(`totalSupply is ${totalSupply}`)

    const writeContract = new Contract(contractAddress, ABI, wallet)
    const contractTx = await writeContract.transfer("0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC", 654321)
    await contractTx.wait()

    const contractTxHash = contractTx.hash
    console.log(`contractTxHash is ${contractTxHash}`)

    const erc20Balance = await readContract.balanceOf("0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC")
    console.log(`erc20Balance is ${erc20Balance}`)

    // listen
    provider.on("block", async (blockNumber) => {
        console.log(`listen blockNumber is ${blockNumber}`)
        if (blockNumber > 40) {
            provider.off("block")
        }
    })
}
ethers_main()