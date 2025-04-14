const hre = require("hardhat");

async function main() {
  console.log("开始部署合约...");

  // 部署逻辑合约

  const logicContract = await hre.run("deploy-revive", {
    contract: "LogicContract",
    args: "",
  });
  const logicAddress = await logicContract.getAddress();
  console.log(`LogicContract 已部署到: ${logicAddress}`);

  // 部署代理合约，传入逻辑合约地址

  const proxyContract = await hre.run("deploy-revive", {
    contract: "ProxyContract",
    args: logicAddress,
  });

  const proxyAddress = await proxyContract.getAddress();
  console.log(`ProxyContract 已部署到: ${proxyAddress}`);

  // 初始化代理合约
  const tx = await proxyContract.initialize();
  await tx.wait();
  console.log("ProxyContract 已初始化");

  // 获取代理合约的当前值
  const currentValue = await proxyContract.dataValue();
  console.log(`当前值: ${currentValue}`);

  // 通过代理调用 increment 函数
  const incrementTx = await proxyContract.increment();
  await incrementTx.wait();

  // 获取更新后的值
  const newValue = await proxyContract.dataValue();
  console.log(`increment 后的值: ${newValue}`);

  console.log("部署和初始化完成");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
