import { ethers } from "hardhat";
// scripts/deploy.js
async function main() {
  const Storage = await ethers.getContractFactory("Storage");
  const storage = await Storage.deploy({
    gasLimit: ethers.toBigInt(3000000)
  });
  await storage.deployed();
  console.log("Storage deployed to:", storage.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);ru
  });