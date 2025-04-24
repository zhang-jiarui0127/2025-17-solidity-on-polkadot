import { ethers } from "ethers";
import { humanReadableABI, BYTECODE } from "./erc20"

async function main() {
    // 设置本地测试节点为provider
    const url = "http://127.0.0.1:8545"
    const providerLocal = new ethers.JsonRpcProvider(url)

    // 利用私钥和provider创建wallet对象
    const privateKey1 = '0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a'
    const wallet1 = new ethers.Wallet(privateKey1, providerLocal)
    const privateKey2 = '0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6'
    const wallet2 = new ethers.Wallet(privateKey2, providerLocal)

    // 1. 查询provider连接到了哪条链
    console.log("1. 查询provider连接到了哪条链")
    const networkLocal = await providerLocal.getNetwork();
    console.log(networkLocal.toJSON());

    // 2. 查询区块高度
    console.log("\n2. 查询区块高度")
    const blockNumberLocal = await providerLocal.getBlockNumber();
    console.log(blockNumberLocal);

    // 3. 查询本地测试网钱包的地址和ETH余额
    console.log("\n3. 查询本地测试网钱包的地址和ETH余额");
    const walletAddress1 = await wallet1.getAddress()
    const balance1 = await providerLocal.getBalance(walletAddress1)
    console.log(`本地钱包1的ETH地址: ${walletAddress1}`);
    console.log(`本地钱包1的ETH余额: ${ethers.formatEther(balance1)} ETH`);

    const walletAddress2 = await wallet2.getAddress()
    const balance2 = await providerLocal.getBalance(walletAddress2)
    console.log(`本地钱包2的ETH地址: ${walletAddress2}`);
    console.log(`本地钱包2的ETH余额: ${ethers.formatEther(balance2)} ETH`);

    // 4. 查询钱包历史交易次数
    console.log("\n4. 查询钱包历史交易次数")
    const txCountLocal1 = await providerLocal.getTransactionCount(walletAddress1);
    const txCountLocal2 = await providerLocal.getTransactionCount(walletAddress2);
    console.log(`钱包1历史交易次数: ${txCountLocal1}`);
    console.log(`钱包2历史交易次数: ${txCountLocal2}`);

    // 5. 创建交易请求，查看交易结果
    // 参数：to为接收地址，value为ETH数额
    console.log("\n5. 创建交易请求，查看交易结果")
    const tx = {
        to: walletAddress2,
        value: ethers.parseEther("1.23"),
    }
    // 发送交易，获得收据
    const txRes = await wallet1.sendTransaction(tx)
    // 等待链上确认交易
    const receipt = await txRes.wait()
    console.log("交易的收据")
    console.log(receipt)
    console.log(`本地钱包1的ETH余额: ${ethers.formatEther(await providerLocal.getBalance(wallet1))} ETH`);
    console.log(`本地钱包2的ETH余额: ${ethers.formatEther(await providerLocal.getBalance(wallet2))} ETH`);
    console.log(`钱包1历史交易次数: ${await providerLocal.getTransactionCount(wallet1)}`)
    console.log(`钱包2历史交易次数: ${await providerLocal.getTransactionCount(wallet2)}`)

    // 6. 利用contractFactory部署ERC20代币合约
    console.log("\n6. 利用contractFactory部署ERC20代币合约")
    // 传递初始供应量（转换为 wei 单位）
    const decimal = 8
    const initialSupply = ethers.parseUnits("1000000", decimal); // 1,000,000 代币
    const factoryERC20 = new ethers.ContractFactory(humanReadableABI, BYTECODE, wallet1)

    // 部署合约，填入constructor的参数
    const contractCPC = await factoryERC20.deploy("Cyberpunk Coin", "CPC", decimal, initialSupply)
    console.log(`合约地址: ${contractCPC.target}`);
    console.log("部署合约的交易详情")
    console.log(contractCPC.deploymentTransaction())
    console.log("\n等待合约部署上链")
    await contractCPC.waitForDeployment()
    // contractCPC.deployTransaction.wait()
    console.log("合约已上链")

    // 7. 调用mint()函数，给本地钱包1mint 10,000代币
    const contractCPCAddr = contractCPC.target.toString()
    const writeableContract = new ethers.Contract(contractCPCAddr, humanReadableABI, wallet1)
    console.log("\n7. 调用mint()函数, 给自己地址mint 10,000代币")
    console.log(`mint befor 地址中代币余额: ${await writeableContract.balanceOf(wallet1)}`)
    console.log(`合约名称: ${await writeableContract.name()}`)
    console.log(`合约代号: ${await writeableContract.symbol()}`)
    const mintBalance = ethers.parseUnits("10000", decimal)
    const nonce = await providerLocal.getTransactionCount(wallet1)
    let tx1 = await writeableContract.mint(mintBalance, {
        nonce: nonce,
    })
    console.log("等待交易上链")
    await tx1.wait()
    console.log(`mint后地址中代币余额: ${await writeableContract.balanceOf(wallet1)}`)
    console.log(`代币总供给: ${await writeableContract.totalSupply()}`)

    // 8. 调用transfer()函数，给本地钱包2转账1000代币
    console.log("\n8. 调用transfer()函数, 给本地钱包2转账1,000代币")
    tx1 = await writeableContract.transfer(wallet2, "1000")
    console.log("等待交易上链")
    await tx1.wait()
    console.log(`本地钱包2中的代币余额: ${await writeableContract.balanceOf(wallet2)}`)

    // 9. 侦听过滤事件
    console.log("\n9. 侦听过滤Transfer事件")
    console.log("\n利用contract.once(), 监听一次Transfer事件");
    writeableContract.once('Transfer', (from, to, value)=>{
        console.log(
        `${from} -> ${to} ${ethers.formatUnits(ethers.getBigInt(value),6)}`
        )
    })
    // 创建转入交易过滤器, 持续监听特定账户的转入交易事件
    console.log("\n创建转入交易过滤器, 利用contract.on(), 持续监听特定账户的转入交易事件");
    const targetAccount = "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65"
    let filterAccount = writeableContract.filters.Transfer(null, targetAccount)
    console.log("过滤器详情：")
    console.log(filterAccount);
    writeableContract.on(filterAccount, (res) => {
        console.log('---------监听特定账户的转入交易事件--------');
        console.log(
          `${res.args[0]} -> ${res.args[1]} ${ethers.formatUnits(res.args[2],6)}`
        )
    })

}

main()