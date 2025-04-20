import {Contract, ethers, Wallet}  from "ethers"
import {ABI,BYTECODE}  from "./Storage"

async function main() {
    const url = "http://127.0.0.1:8545"
    const provider = new ethers.JsonRpcProvider(url)
    const blockNumber = await provider.getBlockNumber()
    const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    const wallet = new Wallet(privateKey,provider)


    // 部署合约
    const factory = new ethers.ContractFactory(ABI,BYTECODE,wallet)
    const contract = await factory.deploy()
    await contract.waitForDeployment()
    const conractAddress = contract.target.toString()

    //读取合约
    const readContract = new Contract(conractAddress,ABI,provider)
    let number = await readContract.retrieve()
    console.log(`初始 number=:${number}`);

    //写入合约
    const writeContract = new Contract(conractAddress,ABI,wallet)
    const contractTx = await writeContract.store(13)
    const receipt  = await contractTx.wait()
    console.log("交易状态:", receipt.status === 1 ? "成功" : "失败");

    number = await readContract.retrieve()
    console.log(`更新后 number=:${number}`);

    //监控block
    provider.on("block",async(blockNumber) => {
        console.log(`blockNumber is ${blockNumber}`)
        if(blockNumber > 3){
            provider.off("block")
        }
    })

}

main()




//Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass 



