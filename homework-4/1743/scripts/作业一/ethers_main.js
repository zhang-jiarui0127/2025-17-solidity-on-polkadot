const { ethers } = require("ethers");
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

    // 配置提供者和签名者
    const provider = new ethers.JsonRpcProvider(
      "https://westend-asset-hub-eth-rpc.polkadot.io"
    );
    const privateKey = process.env.HA_PRIV_KEY;

    if (!privateKey) {
      throw new Error("请在.env文件中设置HA_PRIV_KEY环境变量");
    }

    const wallet = new ethers.Wallet(privateKey, provider);
    console.log(`使用钱包地址: ${wallet.address}`);

    // 获取当前区块数量
    const blockNumber = await provider.getBlockNumber();
    console.log(`当前区块数量: ${blockNumber}`);

    // 监听新区块
    console.log("\n开始监听新区块...");

    let blockCount = 0;
    provider.on("block", (blockNumber) => {
      blockCount++;
      console.log(
        `检测到新区块: ${blockNumber}，自脚本启动后监听到的区块数量: ${blockCount}`
      );
    });

    // 1. 部署合约
    console.log("\n开始部署Storage合约...");
    const factory = new ethers.ContractFactory(abi, bytecode, wallet);
    const contract = await factory.deploy();

    // 等待部署完成
    await contract.deploymentTransaction()?.wait();
    console.log(`合约已部署到地址: ${contract.target}`);

    // 获取已部署合约的实例
    const deployedContract = new ethers.Contract(contract.target, abi, wallet);

    // 2. 调用合约函数
    console.log("\n调用合约函数...");

    // 获取当前值（初始值应该是0）
    const initialValue = await deployedContract.retrieve();
    console.log(`当前值: ${initialValue}`);

    // 存储新值
    console.log("存储新值...");
    const newValue = 42;
    const tx = await deployedContract.store(newValue);
    const receipt1 = await tx.wait();
    console.log(`已存储新值: ${newValue}`);
    console.log("交易收据:", {
      块号: receipt1?.blockNumber,
      交易哈希: receipt1?.hash,
      gas使用量: receipt1?.gasUsed.toString(),
    });

    // 再次获取值确认更新
    const updatedValue = await deployedContract.retrieve();
    console.log(`更新后的值: ${updatedValue}`);

    // 再次存储另一个值
    console.log("\n存储另一个值...");
    const newerValue = 100;
    const tx2 = await deployedContract.store(newerValue);
    const receipt2 = await tx2.wait();

    console.log("交易收据:", {
      块号: receipt2?.blockNumber,
      交易哈希: receipt2?.hash,
      gas使用量: receipt2?.gasUsed.toString(),
    });

    // 获取最终值
    const finalValue = await deployedContract.retrieve();
    console.log(`最终值: ${finalValue}`);

    // 保持脚本运行30秒以便监听区块
    console.log("\n继续监听区块30秒...");

    // 设置超时以便观察区块生成
    await new Promise((resolve) => setTimeout(resolve, 30000));

    // 移除区块监听
    provider.removeAllListeners("block");

    // 获取最终的区块数量用于比较
    const finalBlockNumber = await provider.getBlockNumber();
    console.log(`\n开始区块数: ${blockNumber}`);
    console.log(`结束区块数: ${finalBlockNumber}`);
    console.log(`30秒内新增区块数: ${finalBlockNumber - blockNumber}`);
    console.log(`监听到的区块数: ${blockCount}`);

    console.log("\n脚本执行完毕!");
  } catch (error) {
    console.error("执行过程中发生错误:", error);
    process.exit(1);
  }
}

// 执行主函数
main();
