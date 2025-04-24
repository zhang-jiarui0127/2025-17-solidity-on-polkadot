const hre = require("hardhat");

async function main() {
  console.log("开始部署Storage合约...");

  // 获取合约工厂
  const Storage = await hre.ethers.getContractFactory("Storage");

  // 部署合约时设置gasLimit
  const storage = await Storage.deploy();

  // 等待部署完成
  await storage.waitForDeployment();

  // 获取合约地址
  const storageAddress = await storage.getAddress();

  console.log(`Storage合约已部署到地址: ${storageAddress}`);

  // 调用store方法存储一个值，同样设置gasLimit
  const storeValue = 42;
  const storeTx = await storage.store(storeValue);
  await storeTx.wait();
  console.log(`已存储值: ${storeValue}`);

  // 调用retrieve方法获取值
  const retrievedValue = await storage.retrieve();
  console.log(`读取到的值: ${retrievedValue}`);
}

// 运行脚本
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
