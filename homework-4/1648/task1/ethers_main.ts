import { ethers } from "ethers";
import { getEtherClient, getEtherWallet, getViemClient, getViemWalletClient } from "./src/wallet";
import { ABI, BYTECODE } from "./src/erc20";


async function main() {
    const provider = getEtherClient();

    // 获取当前区块号
    const blockNumber = await provider.getBlockNumber()
    console.log("blockNumber:", `${blockNumber}`)
    const wallet = getEtherWallet(provider)
    console.log(wallet)

    const balance = await provider.getBalance(wallet.address)
    console.log(`balance is ${balance}`)

    const balanceEth = ethers.formatEther(balance)
    console.log(`balance is ${balanceEth} eth`)

 
    // 发送交易
    try {
        const transfer = {
            to: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
            value: ethers.parseUnits("1000", "ether"),
        };
        // 发送交易
        const tx = await wallet.sendTransaction(transfer);
        console.log("Transaction sent, waiting for confirmation...");

        // 等待交易被包含在区块中
        const receipt = await tx.wait();
        if (receipt) {
            console.log("Transaction confirmed in block:", receipt.blockNumber);
        } else {
            console.log("Transaction failed or was not included in a block.");
        }
    } catch (error) {
        console.error("Error sending transaction:", error);
    }
 

    // 1. 部署合约
    const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet);
    const contract = await factory.deploy();
    const contractAddress = contract.target.toString();
    console.log(`正在部署合约：${contractAddress}`);
    await contract.waitForDeployment();
    console.log(`合约部署成功，地址：${contractAddress}`);
    

    // 2. 操作合约
    const currentNonce = await provider.getTransactionCount(wallet.address);
    console.log(`当前nonce：${currentNonce}`);

    
    const currentContract = new ethers.Contract(contractAddress, ABI, wallet);

    // 注册 event 监听器
    const filter = currentContract.filters.StoreChanged();
    // currentContract.on(filter, (value: number) => {
    //     console.log(`Event StoreChanged emitted with value: ${value}`);
    // });
    currentContract.on("StoreChanged", (value, _event) => {
        console.log(`\n==== 事件触发 ====`);
        console.log(`事件名称: StoreChanged`);
        console.log(`值: ${value.toString()}`);
        console.log(`==================\n`);
      });


    // write
    const tx = await currentContract.store(123456);
    const receipt = await tx.wait();
    console.log(`Transaction hash: ${tx.hash}`);
    console.log(`Transaction confirmed in block ${receipt.blockNumber}`);


    // read
    const value = await currentContract.retrieve();
    console.log(`Stored value: ${value.toString()}`);

    // 3. 监听事件
    provider.once("block", async (blockNumber: number) => {
        console.log("Block number:", blockNumber);
    
        if (blockNumber > 10) {
            provider.off("block");
            console.log("Unsubscribed from block events");
        }
    });
}

main()
