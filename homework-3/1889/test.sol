const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ProxyContract", function () {
    let logicContract;
    let proxyContract;

    beforeEach(async function () {
        const LogicContract = await ethers.getContractFactory("LogicContract");
        const ProxyContract = await ethers.getContractFactory("ProxyContract");

        logicContract = await LogicContract.deploy();
        proxyContract = await ProxyContract.deploy(logicContract.address);
    });

    it("should increment the value through the proxy", async function () {
        expect(await proxyContract.getValue()).to.equal(0);
        await proxyContract.increment();
        expect(await proxyContract.getValue()).to.equal(1);
        await proxyContract.increment();
        expect(await proxyContract.getValue()).to.equal(2);
    });
});