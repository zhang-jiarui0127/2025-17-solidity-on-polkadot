import {Contract, ethers, Wallet} from "ethers";
import {ABI, BYTECODE} from "./meta/storage";

async function ethers_main() {
    // 0. local anvil
    const url = "http://127.0.0.1:8545"

    const provider = new ethers.JsonRpcProvider(url)
    const block = await provider.getBlockNumber()
    console.log(`current block is ${block}`)

    // 1. wallet basic
    const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    const wallet = new Wallet(privateKey, provider)
    const address = wallet.address
    const balance = await provider.getBalance(address)
    const ethValue = ethers.formatEther(balance)
    const nonce = await provider.getTransactionCount(address)
    console.log(`current address is ${address}, balance is ${balance}, ethValue is ${ethValue}, nonce is ${nonce}`)

    // 2. wallet transfer
    const transfer = {
        to: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
        value: "1000000000"
    }
    const tx = await wallet.sendTransaction(transfer)
    await tx.wait()

    // 3. deploy contract and interact with it.
    const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet)
    const contract = await factory.deploy()
    await contract.waitForDeployment()
    const contractAddress = contract.target.toString()
    console.log(`contract address is ${contractAddress}`)

    const deployedContract = new Contract(contractAddress, ABI, wallet)
    const number0 = await deployedContract.retrieve()
    console.log(`current number is ${number0}`)

    const tx1 = await deployedContract.store(1024)
    await tx1.wait()

    const number1 = await deployedContract.retrieve()
    console.log(`current number is ${number1}`)

    // 4. get transaction receipt
    const receipt = await provider.getTransactionReceipt(tx1.hash)
    const data = receipt?.fee ? ethers.formatEther(receipt.fee) : "0"
    console.log(`result is ${data} `)

    // 5. listen to block.
    provider.on("block", (blockNumber) => {
        console.log(`current block ${blockNumber}`)
        if (blockNumber > 10) {
            provider.off("block")
        }
    }).then(r => {})
}

export { ethers_main }
