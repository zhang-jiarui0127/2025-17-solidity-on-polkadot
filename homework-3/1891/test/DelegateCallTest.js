const { expect } = require("chai");
const hre = require("hardhat");
const ethers = hre.ethers;

describe(function() {
    let logic, proxy;
    let owner, addr1;

    beforeEach(async function() {
        const signers = await hre.ethers.getSigners();
        owner = signers[0];
        addr1 = signers[1];

        const Logic = await ethers.getContractFactory("Logic");
        logic = await Logic.deploy();
        await logic.waitForDeployment();

        const Proxy = await ethers.getContractFactory("Proxy");
        proxy = await Proxy.deploy(logic.address);
        await proxy.waitForDeployment();
    });

    it(async function() {
        const proxyAsLogic = await ethers.getContractAt("Logic", proxy.address);

        const testValue = 42;
        await proxyAsLogic.setValue(testValue);
        expect(await proxyAsLogic.value()).to.equal(testValue);
        expect(await proxyAsLogic.sender()).to.equal(owner.address);
        expect(await logic.value()).to.equal(0);
        expect(await logic.sender()).to.equal(ethers.ZeroAddress);
    });

    it(async function() {
        const testValue = 100;
        await proxy.setValue(testValue);

        const proxyAsLogic = await ethers.getContractAt("Logic", proxy.address);

        expect(await proxyAsLogic.value()).to.equal(testValue);
        expect(await proxyAsLogic.sender()).to.equal(owner.address);
    });

    it( async function() {
        const proxyAsLogic = await ethers.getContractAt("Logic", proxy.address);
        const testValue = 200;
        await proxyAsLogic.connect(addr1).setValue(testValue);
        expect(await proxyAsLogic.sender()).to.equal(addr1.address);
    });
});