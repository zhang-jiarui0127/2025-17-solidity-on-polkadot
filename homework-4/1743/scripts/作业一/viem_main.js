const {
  createPublicClient,
  createWalletClient,
  http,
  parseAbi,
  getContractAddress,
  encodeDeployData,
} = require("viem");
const { privateKeyToAccount } = require("viem/accounts");
const dotenv = require("dotenv");
const fs = require("fs");
const path = require("path");

// 加载环境变量
dotenv.config();

// 读取合约ABI和字节码
const contractPath = path.join(
  __dirname,
  "../../artifacts-pvm/contracts/Storage.sol/Storage.json"
);
const artifactFile = fs.readFileSync(contractPath, "utf8");
const contractArtifact = JSON.parse(artifactFile);
const abi = contractArtifact.abi;
const bytecode = contractArtifact.bytecode;

async function main() {
  try {
    console.log("开始执行脚本...");

    // 创建公共客户端用于读取区块链
    const publicClient = createPublicClient({
      transport: http("https://westend-asset-hub-eth-rpc.polkadot.io"),
    });

    // 获取私钥
    const privateKey = process.env.HA_PRIV_KEY;
    if (!privateKey) {
      throw new Error("请在.env文件中设置HA_PRIV_KEY环境变量");
    }

    // 创建账户和钱包客户端
    const account = privateKeyToAccount(`0x${privateKey}`);
    console.log(`使用钱包地址: ${account.address}`);

    // 创建钱包客户端用于发送交易
    const walletClient = createWalletClient({
      account,
      transport: http("https://westend-asset-hub-eth-rpc.polkadot.io"),
    });

    // 获取当前区块数量
    const blockNumber = await publicClient.getBlockNumber();
    console.log(`当前区块数量: ${blockNumber}`);

    // 监听新区块
    console.log("\n开始监听新区块...");

    let blockCount = 0;
    const unwatch = publicClient.watchBlockNumber({
      onBlockNumber: (newBlockNumber) => {
        blockCount++;
        console.log(
          `检测到新区块: ${newBlockNumber}，自脚本启动后监听到的区块数量: ${blockCount}`
        );
      },
      emitMissed: true,
      emitOnBegin: true,
    });

    // 1. 部署合约
    console.log("\n开始部署Storage合约...");

    // 部署合约需要分两步：
    // 1. 创建部署交易，并获取合约地址
    const txHash = await walletClient.deployContract({
      abi,
      bytecode,
      account,
    });

    console.log(`部署交易哈希: ${txHash}`);

    // 等待交易被挖出
    const receipt = await publicClient.waitForTransactionReceipt({
      hash: txHash,
    });
    const contractAddress = receipt.contractAddress;

    console.log(`合约已部署到地址: ${contractAddress}`);

    // 2. 调用合约函数
    console.log("\n调用合约函数...");

    // 获取当前值
    const initialValue = await publicClient.readContract({
      address: contractAddress,
      abi,
      functionName: "retrieve",
    });

    console.log(`当前值: ${initialValue}`);

    // 存储新值
    console.log("存储新值...");
    const newValue = 42n;

    const storeTxHash = await walletClient.writeContract({
      address: contractAddress,
      abi,
      functionName: "store",
      args: [newValue],
    });

    // 等待交易被确认
    const storeReceipt = await publicClient.waitForTransactionReceipt({
      hash: storeTxHash,
    });

    console.log(`已存储新值: ${newValue}`);
    console.log("交易收据:", {
      块号: storeReceipt.blockNumber,
      交易哈希: storeReceipt.transactionHash,
      gas使用量: storeReceipt.gasUsed.toString(),
    });

    // 再次获取值确认更新
    const updatedValue = await publicClient.readContract({
      address: contractAddress,
      abi,
      functionName: "retrieve",
    });

    console.log(`更新后的值: ${updatedValue}`);

    // 再次存储另一个值
    console.log("\n存储另一个值...");
    const newerValue = 100n;

    const storeTxHash2 = await walletClient.writeContract({
      address: contractAddress,
      abi,
      functionName: "store",
      args: [newerValue],
    });

    // 等待交易被确认
    const storeReceipt2 = await publicClient.waitForTransactionReceipt({
      hash: storeTxHash2,
    });

    console.log("交易收据:", {
      块号: storeReceipt2.blockNumber,
      交易哈希: storeReceipt2.transactionHash,
      gas使用量: storeReceipt2.gasUsed.toString(),
    });

    // 获取最终值
    const finalValue = await publicClient.readContract({
      address: contractAddress,
      abi,
      functionName: "retrieve",
    });

    console.log(`最终值: ${finalValue}`);

    // 保持脚本运行30秒以便监听区块
    console.log("\n继续监听区块30秒...");

    // 设置超时以便观察区块生成
    await new Promise((resolve) => setTimeout(resolve, 30000));

    // 移除区块监听
    unwatch();

    // 获取最终的区块数量用于比较
    const finalBlockNumber = await publicClient.getBlockNumber();
    console.log(`\n开始区块数: ${blockNumber}`);
    console.log(`结束区块数: ${finalBlockNumber}`);
    console.log(
      `30秒内新增区块数: ${BigInt(finalBlockNumber) - BigInt(blockNumber)}`
    );
    console.log(`监听到的区块数: ${blockCount}`);

    console.log("\n脚本执行完毕!");
  } catch (error) {
    console.error("执行过程中发生错误:", error);
    console.error("错误详情:", error.message);
    if (error.cause) {
      console.error("错误原因:", error.cause);
    }
    process.exit(1);
  }
}

// 执行主函数
main();
