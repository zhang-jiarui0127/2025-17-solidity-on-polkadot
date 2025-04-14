import { Contract, ethers, Wallet } from 'ethers';

import config from './config';
import { ABI, BYTECODE } from "./abi/storage"


async function main() {
    const provider = new ethers.JsonRpcProvider(config.localRpcUrl);
    const blockNumber = await provider.getBlockNumber();
    console.log(`blockNumber: ${blockNumber}`);
    const wallet = new ethers.Wallet(config.privateKey, provider);
    // const wallet = new Wallet(config.privateKey, provider);
    const walletAddress = await wallet.getAddress();
    console.log("wallet address: ", wallet.address);
    console.log("wallet address: ", walletAddress);
    const balance = await provider.getBalance(walletAddress);
    console.log("balance: ", balance.toString());
    const nonce = await provider.getTransactionCount(walletAddress);
    console.log("nonce: ", nonce);
    const tx = await wallet.sendTransaction({
        to: config.accountAddress2,
        value: ethers.parseEther('0.1'),
        nonce: nonce,
    })
    await tx.wait();
    const txHash = tx.hash;
    console.log("tx hash: ", txHash);
    const txReceipt = await provider.getTransactionReceipt(txHash);
    console.log("tx receipt: ", txReceipt);

    const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet)
    const contract = await factory.deploy()
    // 4. 等待部署确认
    await contract.waitForDeployment()
    const contractAddress = await contract.getAddress();

    const contractAddress1 = contract.target.toString()

    console.log("contract address: ", contractAddress)
    console.log("contract address1: ", contractAddress1)
    const deployedContract = new Contract(contractAddress, ABI, provider)
    const retrieve = await deployedContract.retrieve()
    console.log("retrieve: ", retrieve.toString())

}

main().catch((error) => {
    console.error("Error:", error);
    process.exit(1);
});
