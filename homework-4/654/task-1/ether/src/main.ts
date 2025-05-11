import {Contract, ethers, Transaction, Wallet} from "ethers"
import { read } from "fs"
import {ABI, BYTECODE} from "./erc20"

async function main(){
    const url = "http://127.0.0.1:8545" // 本地node节点的url
    const provider = new ethers.JsonRpcProvider(url)    // 提供商
    const blockNumber = await provider.getBlockNumber()     // 获取链上的区块号
    console.log(`result is ${blockNumber}`)
    const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" // 私钥
    const wallet = new Wallet(privateKey, provider) // 创建钱包
    const walletAddress = wallet.address    // 获取钱包地址
    console.log(`result is: wallet address ${walletAddress}`)

    // 获取余额
    const balance = await provider.getBalance(wallet)
    const nonce = await provider.getTransactionCount(walletAddress)
    console.log(`result is: balance ${balance}`)
    console.log(`result is: nonce ${nonce}`)

    // 交易
    const transfer = {
        to: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
        value: "19890401"
    }
 
    const tx = await wallet.sendTransaction(transfer)
    await tx.wait()

    const hash = tx.hash
    console.log(`result is: hash ${hash}`)


    // 部署合约，参数为合约的ABI，BYTECODE，provide
    const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet)
    const contract = await factory.deploy("daijinwei", "OKKB", 18, 10000 )
    await contract.waitForDeployment()
    const contractAddress = contract.target.toString()
    console.log(`result is: contractAddress ${contractAddress}`)

    const readContract = new Contract(contractAddress, ABI, provider)
    const totalSupply =  await readContract.totalSupply()
    console.log(`result is: totalSupply ${totalSupply}`)
    const writeContract = new Contract(contractAddress, ABI, wallet)
    const contractTx = await writeContract.trasfer("0x70997970C51812dc3A010C7d01b50e0d17dc79C8", 12345678)
    await contractTx.wait()

    const contractTxHash = contractTx.hash

    const erc20BalanceOf = await readContract.balanceOf("0x70997970C51812dc3A010C7d01b50e0d17dc79C8")

    console.log(`result is: erc20BalanceOf ${erc20BalanceOf}`)
}

main()