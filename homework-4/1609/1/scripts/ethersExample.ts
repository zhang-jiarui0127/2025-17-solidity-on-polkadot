import { Contract, ethers, Wallet } from "ethers";
import { ABI, BYTECODE } from "./contractData";

async function main() {
    const url = "http://127.0.0.1:8545"
    const provider = new ethers.JsonRpcProvider(url)
    const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    const wallet = new Wallet(privateKey, provider)
    const address = wallet.address

    const transfer = {
        to: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
        value: "1000000000"
    }
    const tx = await wallet.sendTransaction(transfer)
    await tx.wait()
    //查看是转账
    const balance = await provider.getBalance(address)
    console.log("余额:", balance.toString())
    // 部署合约
    console.log("正在部署合约...")
    const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet)
    const contract = await factory.deploy()
    await contract.waitForDeployment()
    const contractAddress = await contract.getAddress()
    console.log("合约已部署到地址:", contractAddress)

    const contractInstance = new ethers.Contract(contractAddress, ABI, wallet)
    const aaa = await contractInstance.store(89)
    await aaa.wait()
    const bbb = await contractInstance.retrieve()
    console.log("存储的值:", bbb.toString())
    
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error)
        process.exit(1)
    })