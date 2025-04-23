import {
    loadFixture,
  } from "@nomicfoundation/hardhat-toolbox/network-helpers";
  import { expect } from "chai";
  import hre from "hardhat";
  
  describe("Storage", function () {
    async function deployOneYearLockFixture() {
      const [owner, otherAccount] = await hre.ethers.getSigners();
      const s = await hre.ethers.getContractFactory("Storage");
      const storage = await s.deploy();
  
      return { storage, owner, otherAccount };
    }
  
    describe("Deployment", function () {
      it("Should set and read variable", async function () {
        const { storage } = await loadFixture(deployOneYearLockFixture);
        const num = 100;
        await storage.store(num)
  
        expect(await storage.retrieve()).to.equal(num);
      });
    });
  });
  