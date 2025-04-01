const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ProxyContract", function () {
  it("should update count through delegatecall", async function () {
    // Deploy LogicContract
    const LogicContract = await ethers.getContractFactory("LogicContract");
    const logicContract = await LogicContract.deploy();
    await logicContract.deployed();

    // Deploy ProxyContract
    const ProxyContract = await ethers.getContractFactory("ProxyContract");
    const proxyContract = await ProxyContract.deploy();
    await proxyContract.deployed();

    // Call increment through ProxyContract
    await proxyContract.delegateIncrement(logicContract.address);

    // Verify the count is updated
    const count = await proxyContract.count();
    expect(count).to.equal(1);
  });
});
