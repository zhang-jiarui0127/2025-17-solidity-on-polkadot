const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Delegatecall Proxy Test", function () {
    let logic, proxy, logicContract, proxyContract, proxyInstance;

    before(async function () {
        // 部署 Logic 合约
        logicContract = await ethers.getContractFactory("Logic");
        logic = await logicContract.deploy();
        await logic.waitForDeployment();  // Ethers v6 使用 waitForDeployment()

        // 部署 Proxy 合约，并传入 Logic 合约地址
        proxyContract = await ethers.getContractFactory("Proxy");
        proxy = await proxyContract.deploy(await logic.getAddress());
        await proxy.waitForDeployment();

        // 连接 Proxy 合约，使其具有 Logic 合约的 ABI
        proxyInstance = await ethers.getContractAt("Logic", await proxy.getAddress());
    });

    it("should increment count via delegatecall", async function () {
        // 先检查初始值
        expect(await proxyInstance.count()).to.equal(0);

        // 调用代理合约的 increment 方法
        const tx = await proxyInstance.increment();
        await tx.wait();

        // 代理合约的 storage 变化，确保 count 正确更新
        expect(await proxyInstance.count()).to.equal(1);

        // 检查 Logic 合约的 storage 是否未改变
        expect(await logic.count()).to.equal(0);
    });
});
