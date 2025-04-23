import { Contract, ethers, Wallet } from 'ethers';

import config from '../config';
import { ABI, BYTECODE } from "../abi/storage";

console.log(config.localRpcUrl); // Outputs: localhost

async function main() {
    const provider = new ethers.JsonRpcProvider(config.localRpcUrl);
    const blockNumber = await provider.getBlockNumber();
    console.log(`blockNumber: ${blockNumber}`);
    // const wallet = new ethers.Wallet(config.privateKey, provider);
    const wallet = new Wallet(config.privateKey, provider);
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


    const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet);
    const contract = await factory.deploy()
    await contract.waitForDeployment();
    const contractAddress1 = await contract.getAddress();
    console.log("contract address1: ", contractAddress1);
    const contractAddress = contract.target.toString();
    console.log("contract address: ", contractAddress);

    const deployedContract = new Contract(contractAddress, ABI, provider)
    const retrieve = await deployedContract.retrieve()
    console.log("retrieve: ", retrieve.toString());

    const walletContract = new Contract(contractAddress, ABI, wallet)
    const storeTx = await walletContract.store(100);
    await storeTx.wait();
    const retrieve2 = await deployedContract.retrieve()
    console.log("retrieve2: ", retrieve2.toString());

    const receipt = await provider.getTransactionReceipt(storeTx.hash)
    const data = receipt?.fee ? ethers.formatEther(receipt.fee) : "0"

    console.log(`result is ${data} `)

}

main().catch((error) => {
    console.error("Error:", error);
    process.exit(1);
});
