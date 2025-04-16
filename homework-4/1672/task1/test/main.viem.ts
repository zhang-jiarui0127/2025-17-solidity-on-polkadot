import { createPublicClient, createWalletClient, http, parseEther, formatEther, getContract, PublicClient, WalletClient, Address, Transport, Chain, Account } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { hardhat } from "viem/chains";
// 直接从编译后的 JSON 文件导入 ABI 和字节码
import storageJson from "../artifacts/contracts/Storage.sol/Storage.json";

async function main() {
    console.log("Hello World hardhat");
    const url = "http://127.0.0.1:8545";
    
    // 创建公共客户端和钱包客户端
    const publicClient = createPublicClient({
        chain: hardhat,
        transport: http(url)
    });
    
    //获取区块高度
    await getBlockNumber(publicClient);
    console.log("--------------------------------");

    //获取余额
    const account = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
    await getBalance(account, publicClient);
    console.log("--------------------------------");

    //转账
    const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
    const to = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";
    const amount = parseEther("1");
    const tx = await sendTransfer(to, amount, privateKey, publicClient);
    console.log("--------------------------------");

    //部署合约
    const contractAddress = await deployContract(privateKey, publicClient);
    console.log("--------------------------------");

    //测试合约事件
    await testContractEvents(contractAddress, privateKey, publicClient);
}

// 修改部署合约函数
async function deployContract(privateKey: string, publicClient: PublicClient): Promise<Address> {
    const account = privateKeyToAccount(privateKey as `0x${string}`);
    console.log(`部署合约的钱包地址: ${account.address}`);
    
    // 创建钱包客户端
    const walletClient = createWalletClient({
        account,
        chain: hardhat,
        transport: http("http://127.0.0.1:8545")
    });
    
    try {
        console.log("开始部署合约...");
        
        // 使用从 JSON 文件导入的 ABI 和字节码
        const abi = storageJson.abi;
        const bytecode = storageJson.bytecode;
        
        console.log("字节码长度:", bytecode.length);
        console.log("字节码前几个字符:", bytecode.substring(0, 10));
        
        // 部署合约
        console.log("部署合约...");
        const hash = await walletClient.deployContract({
            abi,
            bytecode: bytecode as `0x${string}`,
            account,
            gas: 5000000n
        });
        
        console.log("部署交易哈希:", hash);
        
        // 等待交易确认
        console.log("等待部署确认...");
        const receipt = await publicClient.waitForTransactionReceipt({ hash });
        
        if (!receipt.contractAddress) {
            throw new Error("部署交易未创建合约地址");
        }
        
        const contractAddress = receipt.contractAddress;
        console.log(`合约部署地址: ${contractAddress}`);
        
        // 验证部署
        const code = await publicClient.getBytecode({ address: contractAddress });
        console.log(`部署后的合约代码长度: ${code ? code.length : 0}`);
        
        if (!code || code === '0x') {
            throw new Error('合约部署失败，代码为空');
        }
        
        console.log("合约部署成功");
        return contractAddress;
    } catch (error: any) {
        console.error("合约部署错误:", error);
        
        // 打印特定错误信息
        if (error.code) {
            console.log(`错误代码: ${error.code}`);
        }
        
        if (error.reason) {
            console.log(`错误原因: ${error.reason}`);
        }
        
        throw error;
    }
}

// 定义Storage合约类型
type StorageContract = {
    address: Address;
    abi: typeof storageJson.abi;
    read: {
        retrieve: () => Promise<bigint>;
        add: (args: [bigint, bigint]) => Promise<bigint>;
        owner: () => Promise<Address>;
    };
    write: {
        store: (args: [bigint], options?: {gas?: bigint, nonce?: bigint}) => Promise<`0x${string}`>;
        addMessage: (args: [string], options?: {gas?: bigint, nonce?: bigint}) => Promise<`0x${string}`>;
    };
};

// 测试合约事件函数
async function testContractEvents(
    contractAddress: Address,
    privateKey: string, 
    publicClient: PublicClient
) {
    console.log("开始测试合约事件...");
    console.log(`合约地址: ${contractAddress}`);
    
    const account = privateKeyToAccount(privateKey as `0x${string}`);
    const walletClient = createWalletClient({
        account,
        chain: hardhat,
        transport: http("http://127.0.0.1:8545")
    });
    
    // 获取当前nonce
    let currentNonce = await publicClient.getTransactionCount({
        address: account.address
    });
    console.log(`当前钱包 nonce: ${currentNonce}`);

    // 创建合约实例
    const contract = getContract({
        address: contractAddress,
        abi: storageJson.abi,
        client: {
            public: publicClient,
            wallet: walletClient
        }
    }) as unknown as StorageContract;

    // 创建事件检测标志
    let numberStoredEventReceived = false;
    let messageAddedEventReceived = false;
    
    // 设置事件监听器
    console.log("设置事件监听器...");
    
    // 监听 NumberStored 事件
    const unwatch = publicClient.watchContractEvent({
        address: contractAddress,
        abi: storageJson.abi,
        eventName: 'NumberStored',
        onLogs: (logs: any[]) => {
            for (const log of logs) {
                console.log("✅ NumberStored 事件已触发:");
                console.log(`  - 发送者: ${log.args.from}`);
                console.log(`  - 存储的数值: ${log.args.number.toString()}`);
                numberStoredEventReceived = true;
            }
        }
    });
    
    // 监听 MessageAdded 事件
    const unwatchMessage = publicClient.watchContractEvent({
        address: contractAddress,
        abi: storageJson.abi,
        eventName: 'MessageAdded',
        onLogs: (logs: any[]) => {
            for (const log of logs) {
                console.log("✅ MessageAdded 事件已触发:");
                console.log(`  - 消息内容: ${log.args.message}`);
                messageAddedEventReceived = true;
            }
        }
    });

    try {
        // 验证合约代码
        const code = await publicClient.getBytecode({ address: contractAddress });
        if (!code || code === '0x') {
            throw new Error('合约代码不存在');
        }
        console.log(`合约代码已验证，长度: ${code.length}`);

        // 测试纯函数调用
        console.log("测试 add 函数...");
        const sum = await contract.read.add([5n, 7n]);
        console.log(`5 + 7 = ${sum}`);

        // 存储一个值
        console.log("调用 store 函数...");
        // 注意：store 函数要求数字大于0（validNumber修饰器）
        const storeHash = await contract.write.store([100n], {
            gas: 200000n,
            nonce: BigInt(currentNonce++)
        });
        console.log(`已发送 store 交易，nonce: ${currentNonce-1}`);
        console.log("等待交易确认...");
        const receipt = await publicClient.waitForTransactionReceipt({ hash: storeHash });
        console.log(`Store 交易已确认，交易哈希: ${receipt.transactionHash}`);
        
        // 等待事件响应
        console.log("等待 NumberStored 事件响应...");
        await new Promise(resolve => setTimeout(resolve, 2000));
        
        // 验证事件是否被触发
        if (numberStoredEventReceived) {
            console.log("✅ NumberStored 事件验证成功");
        } else {
            console.log("❌ NumberStored 事件未被触发");
        }
        
        // 读取存储的值
        console.log("调用 retrieve 函数...");
        const value = await contract.read.retrieve();
        console.log(`存储的值: ${value}`);

        // 添加一条消息
        console.log("调用 addMessage 函数...");
        const msgHash = await contract.write.addMessage(["Hello Ethereum!"], {
            gas: 200000n,
            nonce: BigInt(currentNonce++) // 使用递增的 nonce
        });
        console.log(`已发送 addMessage 交易，nonce: ${currentNonce-1}`);
        
        // 等待交易确认
        console.log("等待 addMessage 交易确认...");
        await publicClient.waitForTransactionReceipt({ hash: msgHash });
        console.log("消息已添加");
        
        // 等待事件响应
        console.log("等待 MessageAdded 事件响应...");
        await new Promise(resolve => setTimeout(resolve, 2000));
        
        // 验证事件是否被触发
        if (messageAddedEventReceived) {
            console.log("✅ MessageAdded 事件验证成功");
        } else {
            console.log("❌ MessageAdded 事件未被触发");
        }
        
        console.log("合约测试完成");
    } catch (error: any) {
        console.error("合约调用错误:", error);
        
        if (error?.reason) {
            console.log("错误原因:", error.reason);
        }
        
        if (error?.transaction) {
            console.log("交易信息:", {
                to: error.transaction.to,
                from: error.transaction.from,
                data: error.transaction.data?.substring(0, 20) + "...",
                nonce: error.transaction.nonce
            });
        }
        
        if (error?.code) {
            console.log("错误代码:", error.code);
        }
    } finally {
        // 移除事件监听器
        unwatch();
        unwatchMessage();
        console.log("事件监听器已移除");
    }
}

//获取区块高度
async function getBlockNumber(publicClient: PublicClient) {
    const blockNumber = await publicClient.getBlockNumber();
    console.log(`Block number: ${blockNumber}`);
}

//获取账户地址和余额
async function getBalance(address: string, publicClient: PublicClient) {
    const balance = await publicClient.getBalance({
        address: address as `0x${string}`
    });
    console.log(`${address} Balance: ${balance}`);
}

//转账
async function sendTransfer(
    to: string, 
    value: bigint, 
    privateKey: string, 
    publicClient: PublicClient
) {
    const account = privateKeyToAccount(privateKey as `0x${string}`);
    const walletClient = createWalletClient({
        account,
        chain: hardhat,
        transport: http("http://127.0.0.1:8545")
    });
    
    const hash = await walletClient.sendTransaction({
        to: to as `0x${string}`,
        value: value,
        account
    });
    
    console.log(`Transfer: ${hash}`);
    
    //等待交易确认
    await publicClient.waitForTransactionReceipt({ hash });
    
    const walletBalance = await publicClient.getBalance({ address: account.address });
    const toBalance = await publicClient.getBalance({ address: to as `0x${string}` });
    
    console.log(`wallet balance: ${walletBalance}`);
    console.log(`to balance: ${toBalance}`);
    
    return hash;
}

main();
