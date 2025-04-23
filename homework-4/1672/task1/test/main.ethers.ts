import { ethers } from "ethers";
// 直接从编译后的 JSON 文件导入 ABI 和字节码
import storageJson from "../artifacts/contracts/Storage.sol/Storage.json";

async function main() {
    console.log("Hello World hardhat");
    const url="http://127.0.0.1:8545";
    const provider = new ethers.JsonRpcProvider(url);
    //获取区块高度
    await getBlockNumber(provider);
    console.log("--------------------------------");

    //获取余额
    const account = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
    await getBalance(account, provider);
    console.log("--------------------------------");

    //转账
    const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
    const to = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";
    const amount = ethers.parseEther("1");
    const tx = await sendTransfer(to, amount, privateKey, provider);
    // 等待转账交易完成
    await tx.wait();
    console.log("--------------------------------");

    //部署合约
    const contract = await deployContract(privateKey, provider);
    console.log("--------------------------------");

    //测试合约事件
    await testContractEvents(contract, privateKey, provider);
}

// 首先定义合约接口
interface StorageContract extends ethers.BaseContract {
    store(number: bigint, overrides?: ethers.Overrides): Promise<ethers.ContractTransactionResponse>;
    retrieve(): Promise<bigint>;
    addMessage(message: string, overrides?: ethers.Overrides): Promise<ethers.ContractTransactionResponse>;
    owner(): Promise<string>;
    add(a: bigint, b: bigint): Promise<bigint>;
    // 其他合约方法...
}

// 修改部署合约函数
async function deployContract(privateKey: string, provider: ethers.JsonRpcProvider): Promise<StorageContract> {
    const wallet = new ethers.Wallet(privateKey, provider);
    console.log(`部署合约的钱包地址: ${wallet.address}`);
    
    try {
        console.log("开始部署合约...");
        
        // 使用从 JSON 文件导入的 ABI 和字节码
        const abi = storageJson.abi;
        const bytecode = storageJson.bytecode;
        
        console.log("字节码长度:", bytecode.length);
        console.log("字节码前几个字符:", bytecode.substring(0, 10));
        
        // 创建合约工厂
        const factory = new ethers.ContractFactory(
            abi, 
            bytecode, 
            wallet
        );
        
        // 部署合约，设置较高的 gasLimit
        console.log("部署合约...");
        const contract = await factory.deploy({
            gasLimit: 5000000 // 设置 gas 限制
        });
        
        console.log("等待部署确认...");
        const tx = await contract.deploymentTransaction();
        
        if (!tx) {
            throw new Error("部署交易未创建");
        }
        
        console.log("部署交易哈希:", tx.hash);
        await tx.wait();
        
        const contractAddress = await contract.getAddress();
        console.log(`合约部署地址: ${contractAddress}`);
        
        // 验证部署
        const code = await provider.getCode(contractAddress);
        console.log(`部署后的合约代码长度: ${code.length}`);
        
        if (code === '0x') {
            throw new Error('合约部署失败，代码为空');
        }
        
        console.log("合约部署成功");
        return contract as unknown as StorageContract;
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

// 修改测试合约事件的函数
async function testContractEvents(
    contract: StorageContract,
    privateKey: string, 
    provider: ethers.JsonRpcProvider
) {
    console.log("开始测试合约事件...");
    const contractAddress = await contract.getAddress();
    console.log(`合约地址: ${contractAddress}`);
    
    const wallet = new ethers.Wallet(privateKey, provider);
    // 获取当前nonce
    let currentNonce = await provider.getTransactionCount(wallet.address);
    console.log(`当前钱包 nonce: ${currentNonce}`);

    // 创建事件检测标志
    let numberStoredEventReceived = false;
    let messageAddedEventReceived = false;
    
    // 设置事件监听器
    console.log("设置事件监听器...");
    
    // 监听 NumberStored 事件
    contract.on("NumberStored", (from, number) => {
        console.log("✅ NumberStored 事件已触发:");
        console.log(`  - 发送者: ${from}`);
        console.log(`  - 存储的数值: ${number.toString()}`);
        numberStoredEventReceived = true;
    });
    
    // 监听 MessageAdded 事件
    contract.on("MessageAdded", (message) => {
        console.log("✅ MessageAdded 事件已触发:");
        console.log(`  - 消息内容: ${message}`);
        messageAddedEventReceived = true;
    });

    try {
        // 验证合约代码
        const code = await provider.getCode(contractAddress);
        if (code === '0x') {
            throw new Error('合约代码不存在');
        }
        console.log(`合约代码已验证，长度: ${code.length}`);

        // 测试纯函数调用
        console.log("测试 add 函数...");
        const sum = await contract.add(BigInt(5), BigInt(7));
        console.log(`5 + 7 = ${sum}`);

        // 存储一个值
        console.log("调用 store 函数...");
        // 注意：store 函数要求数字大于0（validNumber修饰器）
        const storeTx = await contract.store(BigInt(100), {
            gasLimit: 200000,
            nonce: currentNonce++
        });
        console.log(`已发送 store 交易，nonce: ${currentNonce-1}`);
        console.log("等待交易确认...");
        const receipt = await storeTx.wait();
        console.log(`Store 交易已确认，交易哈希: ${receipt?.hash}`);
        
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
        const value = await contract.retrieve();
        console.log(`存储的值: ${value}`);

        // 添加一条消息
        console.log("调用 addMessage 函数...");
        const msgTx = await contract.addMessage("Hello Ethereum!", {
            gasLimit: 200000,
            nonce: currentNonce++ // 使用递增的 nonce
        });
        console.log(`已发送 addMessage 交易，nonce: ${currentNonce-1}`);
        
        // 等待交易确认
        console.log("等待 addMessage 交易确认...");
        await msgTx.wait();
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
        contract.removeAllListeners();
        console.log("事件监听器已移除");
    }
}

//获取区块高度
async function getBlockNumber(provider: ethers.JsonRpcProvider) {
    const blockNumber = await provider.getBlockNumber();
    console.log(`Block number: ${blockNumber}`);
}

//获取账户地址和余额
async function getBalance(address: string, provider: ethers.JsonRpcProvider) {
    const balance = await provider.getBalance(address);
    console.log(address + " Balance: " + balance);
}


//转账
async function sendTransfer(
    to: string, 
    value: bigint, 
    privateKey: string, 
    provider: ethers.JsonRpcProvider
) {
    const wallet = new ethers.Wallet(privateKey, provider);
    const tx = await wallet.sendTransaction({
        to: to,
        value: value
    });
    console.log(`Transfer: ${tx.hash}`);
    //等待交易确认
    await tx.wait();
    console.log(`wallet balance: ${await provider.getBalance(wallet.address)}`);
    console.log(`to balance: ${await provider.getBalance(to)}`);
    return tx;
}



main()
