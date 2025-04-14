import { Contract, ethers, Wallet } from "ethers"
import { ABI, BYTECODE } from "./erc20"

async function main() {
    const url = "http://127.0.0.1:8545"
    const provider = new ethers.JsonRpcProvider(url)
    const block = await provider.getBlockNumber()
    const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    const wallet = new Wallet(privateKey, provider)
    const address = wallet.address
    const balance = await provider.getBalance(address)
    const ethValue = ethers.formatEther(balance)
    const nonce = await provider.getTransactionCount(address)

    const transfer = {
        to: "0x90F79bf6EB2c4f870365E785982E1f101E93b906",
        value: "1000000000"
    }
    const tx = await wallet.sendTransaction(transfer)
    await tx.wait()

    const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet)
    const contract = await factory.deploy("name",
        "symbol", 10, 1000000000)
    await contract.waitForDeployment()
    const contractAddress = contract.target.toString()

    const deployedContract = new Contract(contractAddress, ABI, provider)
    const totalSupply = await deployedContract.totalSupply()

    const walletContract = new Contract(contractAddress, ABI, wallet)
    const tx2 = await walletContract.transfer("0x90F79bf6EB2c4f870365E785982E1f101E93b906", 1)
    await tx2.wait()

    const erc20Balance = await deployedContract.balanceOf("0x90F79bf6EB2c4f870365E785982E1f101E93b906")
    console.log(erc20Balance)


    // it is correct, but if it follows the tx. can't block and wait for event.
    // maybe sth wrong with anvil or hardhat node.
    provider.on("block", (blockNumber) => {
        console.log(`current block ${blockNumber}`)
        if (blockNumber > 55) {
            provider.off("block")
        }
    })

    const receipt = await provider.getTransactionReceipt(tx2.hash)
    const data = receipt?.fee ? ethers.formatEther(receipt.fee) : "0"

    console.log(`result is ${data} `)

}

main()

