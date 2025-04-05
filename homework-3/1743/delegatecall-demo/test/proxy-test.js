const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("代理合约测试", function () {
  // 增加测试超时时间
  this.timeout(120000); // 设置为120秒

  let logicContract;
  let proxyContract;
  let owner;

  before(async function () {
    // 获取测试账户
    [owner] = await ethers.getSigners();
    try {
      // 部署逻辑合约
      logicContract = await hre.run("deploy-revive", {
        contract: "LogicContract",
        args: "",
      });
      const logicAddress = await logicContract.getAddress();

      // 部署代理合约，并传入逻辑合约地址
      proxyContract = await hre.run("deploy-revive", {
        contract: "ProxyContract",
        args: logicAddress,
      });

      // 初始化代理合约
      const tx = await proxyContract.initialize();
      await tx.wait();
    } catch (error) {
      console.error("部署或初始化过程中出错:", error);
      throw error;
    }
  });

  it("应该正确初始化代理合约", async function () {
    // 验证代理合约的 owner 是否正确设置
    expect(await proxyContract.owner()).to.equal(owner.address);

    // 验证代理合约的 dataValue 初始值为 0
    expect(await proxyContract.dataValue()).to.equal(0);
  });

  it("应该通过代理合约正确更新状态", async function () {
    // 调用代理合约的 increment 函数
    const incrementTx = await proxyContract.increment();
    await incrementTx.wait();

    // 验证代理合约的 dataValue 是否增加到 1
    expect(await proxyContract.dataValue()).to.equal(1);

    // 再次调用 increment 函数
    const incrementTx2 = await proxyContract.increment();
    await incrementTx2.wait();

    // 验证代理合约的 dataValue 是否增加到 2
    expect(await proxyContract.dataValue()).to.equal(2);
  });

  it("应该通过事件验证调用成功", async function () {
    // 验证调用 increment 函数时是否正确触发事件
    await expect(proxyContract.increment())
      .to.emit(proxyContract, "IncrementEvent")
      .withArgs(
        owner.address,
        true,
        "0x0000000000000000000000000000000000000000000000000000000000000003"
      );
  });

  it("应该验证代理合约和逻辑合约的状态隔离", async function () {
    // 调用代理合约的 increment 函数
    const incrementTx = await proxyContract.increment();
    await incrementTx.wait();

    // 验证代理合约的 dataValue 增加到 4
    expect(await proxyContract.dataValue()).to.equal(4);

    // 验证逻辑合约的 dataValue 仍然为 0（状态隔离）
    expect(await logicContract.dataValue()).to.equal(0);
  });
});
