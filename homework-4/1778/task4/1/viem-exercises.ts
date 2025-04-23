import { createWalletClient, createPublicClient, http, parseEther, formatEther, parseUnits, formatUnits, getContract, defineChain } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { ABI, BYTECODE } from "./erc20";

async function main() {
    // 设置本地测试节点为client
    const transport = http("http://127.0.0.1:8545");
    const localhost = defineChain({
        id: 31_337,
        name: 'Localhost',
        nativeCurrency: {
          decimals: 18,
          name: 'Ether',
          symbol: 'ETH',
        },
        rpcUrls: {
          default: { http: ['http://127.0.0.1:8545'] },
        },
      })
    
    // 创建public和wallet clients
    const publicClient = createPublicClient({
        chain: localhost,
        transport,
    });
    
    const walletClient1 = createWalletClient({
        chain: localhost,
        transport,
    });
    
    const walletClient2 = createWalletClient({
        chain: localhost,
        transport,
    });

    // 利用私钥创建account对象
    const privateKey1 = '0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a';
    const account1 = privateKeyToAccount(privateKey1);
    const privateKey2 = '0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6';
    const account2 = privateKeyToAccount(privateKey2);

    // 1. 查询client连接到了哪条链
    console.log("1. 查询client连接到了哪条链");
    console.log(localhost);

    // 2. 查询区块高度
    console.log("\n2. 查询区块高度");
    const blockNumberLocal = await publicClient.getBlockNumber();
    console.log(blockNumberLocal);

    // 3. 查询本地测试网钱包的地址和ETH余额
    console.log("\n3. 查询本地测试网钱包的地址和ETH余额");
    const walletAddress1 = account1.address;
    const balance1 = await publicClient.getBalance({ address: walletAddress1 });
    console.log(`本地钱包1的ETH地址: ${walletAddress1}`);
    console.log(`本地钱包1的ETH余额: ${formatEther(balance1)} ETH`);

    const walletAddress2 = account2.address;
    const balance2 = await publicClient.getBalance({ address: walletAddress2 });
    console.log(`本地钱包2的ETH地址: ${walletAddress2}`);
    console.log(`本地钱包2的ETH余额: ${formatEther(balance2)} ETH`);

    // 4. 查询钱包历史交易次数
    console.log("\n4. 查询钱包历史交易次数");
    const txCountLocal1 = await publicClient.getTransactionCount({ address: walletAddress1 });
    const txCountLocal2 = await publicClient.getTransactionCount({ address: walletAddress2 });
    console.log(`钱包1历史交易次数: ${txCountLocal1}`);
    console.log(`钱包2历史交易次数: ${txCountLocal2}`);

    // 5. 创建交易请求，查看交易结果
    console.log("\n5. 创建交易请求，查看交易结果");
    const txHash = await walletClient1.sendTransaction({
        account: account1,
        to: walletAddress2,
        value: parseEther("1.23"),
    });
    
    // 等待链上确认交易
    const receipt = await publicClient.waitForTransactionReceipt({ hash: txHash });
    console.log("交易的收据");
    console.log(receipt);
    
    const newBalance1 = await publicClient.getBalance({ address: walletAddress1 });
    const newBalance2 = await publicClient.getBalance({ address: walletAddress2 });
    console.log(`本地钱包1的ETH余额: ${formatEther(newBalance1)} ETH`);
    console.log(`本地钱包2的ETH余额: ${formatEther(newBalance2)} ETH`);
    
    const newTxCount1 = await publicClient.getTransactionCount({ address: walletAddress1 });
    const newTxCount2 = await publicClient.getTransactionCount({ address: walletAddress2 });
    console.log(`钱包1历史交易次数: ${newTxCount1}`);
    console.log(`钱包2历史交易次数: ${newTxCount2}`);

    // 6. 部署ERC20代币合约
    console.log("\n6. 部署ERC20代币合约");
    const decimal = 8;
    const initialSupply = parseUnits("1000000", decimal); // 1,000,000 代币
    
    const hash = await walletClient1.deployContract({
        account: account1,
        abi: ABI,
        bytecode: `0x${BYTECODE}`,
        args: ["Cyberpunk Coin", "CPC", decimal, initialSupply],
    });
    
    const contractReceipt = await publicClient.waitForTransactionReceipt({ hash });
    const contractCPCAddr = contractReceipt.contractAddress;
    console.log(`合约地址: ${contractCPCAddr}`);
    
    // 获取部署交易详情
    const txDetails = await publicClient.getTransaction({ hash });
    console.log("部署合约的交易详情");
    console.log(txDetails);
    console.log("\n等待合约部署上链");
    console.log("合约已上链");

    // 7. 调用mint()函数，给本地钱包1 mint 10,000代币
    const contractCPC = getContract({
        address: contractCPCAddr!,
        abi: ABI,
        client: { public: publicClient, wallet: walletClient1 },
    });
    
    console.log("\n7. 调用mint()函数, 给自己地址mint 10,000代币");
    console.log(`mint before 地址中代币余额: ${await contractCPC.read.balanceOf([walletAddress1])}`);
    console.log(`合约名称: ${await contractCPC.read.name()}`);
    console.log(`合约代号: ${await contractCPC.read.symbol()}`);
    
    const mintBalance = parseUnits("10000", decimal);
    const { request: mintRequest } = await publicClient.simulateContract({
        account: account1,
        address: contractCPCAddr!,
        abi: ABI,
        functionName: 'mint',
        args: [mintBalance],
    });
    
    const mintTx = await walletClient1.writeContract(mintRequest);
    console.log("等待交易上链");
    await publicClient.waitForTransactionReceipt({ hash: mintTx });
    console.log(`mint后地址中代币余额: ${await contractCPC.read.balanceOf([walletAddress1])}`);
    console.log(`代币总供给: ${await contractCPC.read.totalSupply()}`);

    // 8. 调用transfer()函数，给本地钱包2转账1000代币
    console.log("\n8. 调用transfer()函数, 给本地钱包2转账1,000代币");
    const { request: transferRequest } = await publicClient.simulateContract({
        account: account1,
        address: contractCPCAddr!,
        abi: ABI,
        functionName: 'transfer',
        args: [walletAddress2, 1000n],
    });
    
    const transferTx = await walletClient1.writeContract(transferRequest);
    console.log("等待交易上链");
    await publicClient.waitForTransactionReceipt({ hash: transferTx });
    console.log(`本地钱包2中的代币余额: ${await contractCPC.read.balanceOf([walletAddress2])}`);

    // 9. 侦听过滤事件
    console.log("\n9. 侦听过滤Transfer事件");
    console.log("\n监听一次Transfer事件");
    
    const unwatch = publicClient.watchContractEvent({
        address: contractCPCAddr!,
        abi: ABI,
        eventName: 'Transfer',
        onLogs: (logs) => {
            const transferEvent = logs[0] as unknown as { args: { from: string; to: string; value: bigint } };
            console.log(`${transferEvent.args.from} -> ${transferEvent.args.to} ${formatUnits(transferEvent.args.value, 6)}`);
            unwatch(); // 只监听一次
        },
    });
    
    // 创建转入交易过滤器, 持续监听特定账户的转入交易事件
    console.log("\n创建转入交易过滤器, 持续监听特定账户的转入交易事件");
    const targetAccount = "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65";
    
    const unwatchFilter = publicClient.watchContractEvent({
        address: contractCPCAddr!,
        abi: ABI,
        eventName: 'Transfer',
        args: { to: targetAccount },
        onLogs: (logs) => {
            console.log('---------监听特定账户的转入交易事件--------');
            logs.forEach(log => {
                const transferEvent = logs[0] as unknown as { args: { from: string; to: string; value: bigint } };
                console.log(`${transferEvent.args.from} -> ${transferEvent.args.to} ${formatUnits(transferEvent.args.value, 6)}`);
            });
        },
    });
}

main();