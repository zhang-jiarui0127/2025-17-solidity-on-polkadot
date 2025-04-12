const { ethers } = require("ethers");
const { storageAbi, bytecode } = require("./abi");
const { createPublicClient, createWalletClient, http } = require("viem");
const { hardhat } = require("viem/chains");
const { privateKeyToAccount } = require("viem/accounts"); // 导入转换函数

async function main_ethers() {
    console.log("************************main_ethers************************");
    console.log("Starting ...");
    const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545"); // 替换为你的 RPC 地址
    const wallet = new ethers.Wallet("0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e", provider); 
    console.log("Wallet address:", wallet.address);

    // 获取账户余额
    const balance = await provider.getBalance(wallet.address);
    console.log("Wallet balance:", ethers.formatEther(balance), "ETH");
    const amountInEther = "0.1"; // Replace with the amount you want to send
    const amountInWei = ethers.parseUnits(amountInEther, "ether");

    // 部署合约
    console.log("Deploying contract...");
    const contractFactory = new ethers.ContractFactory(storageAbi, bytecode, wallet);
    const contract = await contractFactory.deploy();
    await contract.deploymentTransaction().wait(); // v6 使用 deploymentTransaction()
    //nonce
    console.log(`Contract deployed at address: ${contract.target}`);
    const nonce = await provider.getTransactionCount(wallet.address, "pending");
    console.log(" nonce:", nonce);

    //check contract
    const code = await provider.getCode(contract.target);
    console.log("constract code:", code);
    if (code === "0x") throw new Error("constract not deployed");

    // 存储数据
    const numberToStore = 42n;
    console.log("numberToStore:", numberToStore.toString());
    const tx = await contract.store(numberToStore);
    const receipt = await tx.wait();
    console.log("receipt tx hash:", receipt.hash);

    // 调用 retrieve 函数
    const storedValue = await contract.retrieve();
    console.log("read numberToStore", storedValue.toString());

    // 检索数据
    console.log("Retrieving data...");
    const value = await contract.retrieve();
    console.log(`Retrieved value: ${value.toString()}`);
    // 侦听事件
    contract.on("NumberChanged", (data) => {
        console.log("Event NumberChanged:", data.toString());
    });
}

async function main_viem() {
    try {
        console.log("Starting ...");
        // 创建钱包客户端
        const privateKey = "0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e";
        const account = privateKeyToAccount(privateKey); // 显式转换为 PrivateKeyAccount

        // 配置客户端
        const publicClient = createPublicClient({
            chain: hardhat,
            transport: http("http://127.0.0.1:8545"),
        });

        const walletClient = createWalletClient({
            chain: hardhat,
            transport: http("http://127.0.0.1:8545"),
            account: account,
        });

        // 验证节点连接
        console.log("Verifying network connection...");
        const chainId = await publicClient.getChainId();
        console.log("Network chainId:", chainId);
        if (chainId !== 31337) throw new Error("Chain ID mismatch! Expected 31337.");


        console.log("Wallet address:", walletClient.account.address);
        console.log("Wallet public key:", walletClient.account.publicKey);
 
        // 2. 获取账户余额
        const balance = await publicClient.getBalance({ address: walletClient.account.address });
        console.log("Wallet balance:", Number(balance) / 1e18, "ETH");

        // 检查 nonce
        const currentNonce = await publicClient.getTransactionCount({
            address: walletClient.account.address,
            blockTag: "pending",
        });
        console.log("Current nonce:", currentNonce);
        // 3. 部署合约
        console.log("Deploying contract...");
        const deployHash = await walletClient.deployContract({
            abi: storageAbi,
            bytecode: bytecode,
            args: [],
            nonce: currentNonce,
        });
        console.log("Deploy transaction hash:", deployHash);
       
        const nonce = await publicClient.getTransactionCount({
            address: walletClient.account.address,
            blockTag: "pending",
        });
        console.log("nonce:", nonce);

        // 检查合约代码
        const code = await publicClient.getBytecode({ address: contractAddress });
        console.log("contract code:", code);
        if (code === "0x" || !code) throw new Error("contract not deployed");

        // 存储数据 (调用 store 函数)
        const numberToStore = BigInt(42);
        console.log("numberToStore:", numberToStore.toString());
        const txHash = await walletClient.writeContract({
            address: contractAddress,
            abi: storageAbi,
            functionName: "store",
            args: [numberToStore],
        });
        const receipt = await publicClient.waitForTransactionReceipt({ hash: txHash });
        console.log("receipt tx hash:", receipt.transactionHash);

        // 调用 retrieve 函数 (读取数据)
        const storedValue = await publicClient.readContract({
            address: contractAddress,
            abi: storageAbi,
            functionName: "retrieve",
        });
        console.log("read numberToStore:", storedValue.toString());

        //  监听事件
        console.log("Listening for NumberChanged events...");
        publicClient.watchContractEvent({
            address: contractAddress,
            abi: storageAbi,
            eventName: "NumberChanged",
            onLogs: (logs) => {
                logs.forEach((log) => {
                    console.log("Event NumberChanged:", log.args.newNumber.toString());
                });
            },
        });

        // 保持程序运行以监听事件
        await new Promise(() => { });

    } catch (error) {
        console.error("Error:", error);
    }
}

// main_ethers().catch((error) => {
//     console.error("Error:", error);
// });

main_viem().catch((error) => {
    console.error("Error:", error);
});