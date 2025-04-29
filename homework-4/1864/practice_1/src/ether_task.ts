import { Contract, ethers, Wallet } from "ethers";
import { config } from "./config";
import { ABI, BYTECODE } from "./storage";

async function main() {
    // 1. Connect to Anvil local node
    const provider = new ethers.JsonRpcProvider(config.rpcUrl);
    const wallet = new Wallet(config.privateKey, provider);
    
    console.log("Connected to Anvil node");
    console.log("Wallet address:", wallet.address);
    
    // 2. Get initial balance
    const balance = await provider.getBalance(wallet.address);
    console.log("Initial balance:", ethers.formatEther(balance), "ETH");
    
    // 3. Read contract bytecode and ABI
    // use storage.ts as ABI and bytecode
    
    // 4. Deploy contract
    const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet);
    
    console.log("Deploying contract...");

    const contract = await factory.deploy();
    await contract.waitForDeployment();
    
    const contractAddress = contract.target.toString();
    console.log("Contract deployed at:", contractAddress);
    
    // 5. Interact with contract
    const contractFunction = new Contract(contractAddress, ABI, wallet);
    const readContract = new Contract(contractAddress, ABI, provider);


    // 6. test contract
    const tx = await contractFunction.store(100);
    await tx.wait();
    const value = await contractFunction.retrieve();
    console.log("Value:", value.toString());
    

    // 7. Listen for ValueChanged event
    provider.on("block", async (blockNumber) => {
        console.log("blockNumber:", blockNumber);
        if (blockNumber > 25) {
            provider.off("block");
        }
    });

    
    // // 6. Set new value and listen for event
    // console.log("Setting new value...");
    // const newValue = 200;
    // const tx = await contractFunction.setValue(newValue);
    // await tx.wait();
    

    
    // // 8. Transfer ownership and listen for event
    // console.log("Transferring ownership...");
    // const transferTx = await contract.transferOwnership(config.testAddress);
    // await transferTx.wait();
    
    // // 9. Listen for OwnershipTransferred event
    // contract.on("OwnershipTransferred", (previousOwner, newOwner) => {
    //     console.log("OwnershipTransferred event:");
    //     console.log("Previous owner:", previousOwner);
    //     console.log("New owner:", newOwner);
    // });
    
    // // 10. Verify new owner
    // const currentOwner = await contract.owner();
    // console.log("Current owner:", currentOwner);
    
    // // Keep the script running to listen for events
    // console.log("Listening for events...");
}

main().catch((error) => {
    console.error("Error:", error);
    process.exit(1);
});
