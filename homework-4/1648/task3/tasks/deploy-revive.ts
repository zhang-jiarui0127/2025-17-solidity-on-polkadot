import { task } from "hardhat/config"
import { readFileSync } from 'fs'
import { join } from 'path'
import { ethers } from "ethers"

task("deploy-revive", "Deploys a contract")
  .addParam("contract", "The contract name")
  .addOptionalParam("args", "Constructor arguments (comma-separated)")
  .setAction(async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying with:", deployer.address);

    // 获取并打印部署者的余额
    const balance = await hre.ethers.provider.getBalance(deployer.address);
    console.log("Deployer balance:", hre.ethers.formatEther(balance), "ETH");

    const contractName = taskArgs.contract;

    try {
      const abi = JSON.parse(
        readFileSync(
          join("artifacts", "contracts", contractName, `${contractName}.json`),
          "utf8"
        )
      );
      const bytecode = `0x${readFileSync(
        join("artifacts", "contracts", contractName, `${contractName}.polkavm`)
      ).toString("hex")}`;

      // Create contract factory and deploy
      const factory = new hre.ethers.ContractFactory(abi, bytecode, deployer);

      // Log constructor args to verify
   
      const constructorArgs = taskArgs.args
      ? taskArgs.args.split(",").filter(Boolean)
      : [];
    
    console.log("Constructor Arguments:",  constructorArgs);

      // const deployOptions = {
      //   gasLimit: ethers.toBigInt(36451736500281453),
      // };

      // const contract = constructorArgs.length === 0
      //       ? await factory.deploy(deployOptions)
      //       : await factory.deploy(...constructorArgs, deployOptions);

    //   const contract = await factory.deploy(...constructorArgs, {
    //     gasLimit: 3_000_000n
    //   });
        const contract = await factory.deploy(...constructorArgs);

      await contract.waitForDeployment();
      console.log(`${contractName} deployed to:`, await contract.getAddress());
    } catch (error) {
      console.error("Deployment failed:", error);
      process.exit(1);
    }
  });