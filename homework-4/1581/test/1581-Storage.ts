import { expect } from "chai";
import { ethers } from "hardhat";

describe("Storage", function () {
    it("Should store and retrieve number", async function () {
        const Storage = await ethers.getContractFactory("Storage");
        const storage = await Storage.deploy();
        await storage.deployed();

        await storage.store(42);
        expect(await storage.retrieve()).to.equal(42);
    });
});