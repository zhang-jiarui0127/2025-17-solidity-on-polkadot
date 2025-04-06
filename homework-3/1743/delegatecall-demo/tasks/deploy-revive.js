const { task } = require("hardhat/config");
const { readFileSync } = require("fs");
const { join } = require("path");

task("deploy-revive", "Deploys a contract")
  .addParam("contract", "The contract name")
  .addParam("args", "Constructor arguments (comma-separated)")
  .setAction(async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();
    // console.log("Deploying with:", deployer.address);

    const contractName = taskArgs.contract;

    try {
      // console.log(`开始部署 ${contractName}...`);

      // 使用标准的合约工厂方法部署
      const ContractFactory = await hre.ethers.getContractFactory(contractName);

      // 处理构造函数参数
      const constructorArgs = taskArgs.args ? taskArgs.args.split(",") : [];
      // console.log("Constructor Arguments:", constructorArgs);

      // 部署合约
      const contract = await ContractFactory.deploy(...constructorArgs);
      await contract.waitForDeployment();

      const contractAddress = await contract.getAddress();
      // console.log(`${contractName} 已部署到:`, contractAddress);

      // 返回部署的合约实例
      return contract;
    } catch (error) {
      console.error(`部署 ${contractName} 失败:`, error);
      throw error;
    }
  });
