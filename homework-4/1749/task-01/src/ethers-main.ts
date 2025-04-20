import { Contract, ethers, Wallet } from "ethers"
import { ABI, BYTECODE } from "./trc20"

async function main() {
    const url = "http://127.0.0.1:8545"
    const provider = new ethers.JsonRpcProvider(url)
    const blockNumber = await provider.getBlockNumber()
    const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    const wallet = new Wallet(privateKey, provider)
    const walletAddress = wallet.address
    const balance = await provider.getBalance(walletAddress)
    const nonce = await provider.getTransactionCount(walletAddress)

    const transfer = {
        to : "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
        value: "123456"

    }
    const tx = await wallet.sendTransaction(transfer)
    await tx.wait()

    
    // const hash = tx.hash

    // const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet)
    // const contract = await factory.deploy("name","symbol",18,10000000)
    // await contract.waitForDeployment()
    // const contractAddress = contract.target.toString()

    // const readContract = new Contract(contractAddress, ABI, provider)
    // const totalSupply = await readContract.totalSupply()

    // const writeContract = new Contract(contractAddress, ABI, wallet)
    // const contractTx = await writeContract.transfer("0x70997970C51812dc3A010C7d01b50e0d17dc79C8", 123445)
    // await contractTx.wait()
    // const contractTxHash = contractTx.hash


    // const trc20Balance = await readContract.balanceOf("0x70997970C51812dc3A010C7d01b50e0d17dc79C8")


    // console.log(`result is ${tx.hash}`)


    // provider.on("block", async(blockNumber) => {
    //     console.log(`block number is ${blockNumber}`)
    //     if (blockNumber > 17){
    //         provider.off("block")
    //     }
    // })
}

main()