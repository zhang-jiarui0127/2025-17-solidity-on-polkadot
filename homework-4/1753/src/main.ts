import { ethers } from "ethers"
import { ABI, BYTECODE } from "./config"
import { createPublicClient, createWalletClient, defineChain ,hexToBigInt,http } from "viem";
import { privateKeyToAccount } from "viem/accounts";

async function ethersTest(){
    // basic
    const url = "http://localhost:8545"// hardhat node
    const provider = new ethers.JsonRpcProvider(url)
    const blockNumber = await provider.getBlockNumber()
    console.log("blockNumber: ", blockNumber)
    
    // acconut
    const pk = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    const account0 = new ethers.Wallet(pk, provider)
    const account0Adress = await account0.getAddress()
    const balance0 = await provider.getBalance(account0Adress)
    console.log("account0Adress: ", account0Adress)
    console.log(`balance0: ${ethers.formatEther(balance0)} ETH`)

    // transfer
    const tx = {
        to: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
        value: ethers.parseEther("10")
    }
    const transaction = await account0.sendTransaction(tx)
    await transaction.wait()
    console.log("transaction: ", transaction.hash)
    const balance0AfterTx = await provider.getBalance(account0Adress)
    console.log(`balance0: ${ethers.formatEther(balance0AfterTx)} ETH`)

    // contract
    // deploy
    const storageFactory = new ethers.ContractFactory(ABI,BYTECODE,account0)
    const storageContract = await storageFactory.deploy(666)
    await storageContract.waitForDeployment()
    console.log("storageContract address: ", storageContract.target)
    // call(read)
    const readContract = new ethers.Contract(storageContract.target, ABI, provider)
    const number = await readContract.number()
    console.log("number: ", number)
    // call(write)
    const writeContract = new ethers.Contract(storageContract.target, ABI, account0)
    const tx2 = await writeContract.setNumber(888)
    await tx2.wait()
    const newNumber = await readContract.number()
    console.log("newNumber: ", newNumber)

    // event
    provider.on("block", async (blockNumber) => {
        console.log(`New block number: ${blockNumber}`);
    });
    writeContract.on("NumberUpdated",async (newNumber)=>{
        console.log("NumberUpdated: ",newNumber)
    })
}

async function viemTest() {
    // define chain
    const localChain = (url: string) => defineChain({
        id: 31337,
        name: "testnet",
        network: "testnet",
        nativeCurrency: {
            decimals: 18,
            name: "Ether",
            symbol: "ETH",
        },
        rpcUrls: {
            default: {
                http: [url],
            },
            public: {
                http: [url],
            },
        },
        testnet: true,
    });

    // client config
    // public client (read)
    const url = "http://localhost:8545"
    const publicClient = createPublicClient({
        chain: localChain(url),
        transport: http(),
    })
    // wallet client (write)
    const pk = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    const account0 = privateKeyToAccount(pk)
    const walletClient = createWalletClient({
        account: account0,
        chain: localChain(url),
        transport: http(),
    })

    // basic
    const blockNumber = await publicClient.getBlockNumber()
    console.log("blockNumber: ", blockNumber)
    const account0Adress = account0.address
    console.log("account0Adress: ", account0Adress)
    const balance0 = await publicClient.getBalance({address: account0Adress})
    console.log(`balance0: ${ethers.formatEther(balance0)} ETH`)

    // transfer
    const tx = await walletClient.sendTransaction({
        to: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
        value: hexToBigInt("0x100"),
    });
    console.log("transaction: ", tx)

    // contract
    const formatBytecode = `0x${BYTECODE}`
    const storageContract = await walletClient.deployContract({
        abi: ABI,
        bytecode: formatBytecode,
        args: [666],
    })
    // special usage: get contract address
    const receipt = await publicClient.waitForTransactionReceipt({hash: storageContract})
    if (!receipt.contractAddress) {
        throw new Error("Contract deployment failed or no contract address returned.");
    }
    const contractAddress = receipt.contractAddress;
    console.log(`Contract address: ${contractAddress}`);
    // call(read)
    const number = await publicClient.readContract({
        address: contractAddress,// TypeScript now ensures this is non-null
        abi: ABI,
        functionName: "number",
    })
    console.log("number: ", number)
    // call(write)
    await walletClient.writeContract({
        address: contractAddress,
        abi: ABI,
        functionName: "setNumber",
        args: [777],
    })
    const newNumber = await publicClient.readContract({
        address: contractAddress,
        abi: ABI,
        functionName: "number",
    })
    console.log("newNumber: ", newNumber)

    // event
    publicClient.watchBlocks({
        onBlock: (block) => {
            console.log(`New block number: ${block.number}`);
        },
    });
}

async function main() {
    // await ethersTest()
    await viemTest()
}
main()