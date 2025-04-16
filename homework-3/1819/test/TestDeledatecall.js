const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Proxy1819 and Logic1819", function () {
  let Logic1819, Proxy1819, logic1819, proxy1819, owner;

  beforeEach(async function () {
    // 获取账户
    [owner] = await ethers.getSigners();

    // 部署Logic1819合约
    const Logic1819Factory = await ethers.getContractFactory("Logic1819");
    logic1819 = await Logic1819Factory.deploy();
    await logic1819.deployed();

    // 部署Proxy1819合约，传入Logic1819地址
    const Proxy1819Factory = await ethers.getContractFactory("Proxy1819");
    proxy1819 = await Proxy1819Factory.deploy(logic1819.address);
    await proxy1819.deployed();
  });

  it("should increment counter using delegatecall through proxy", async function () {
    // 创建代理合约的接口，调用increment函数
    const proxyWithLogicInterface = await ethers.getContractAt("Logic1819", proxy1819.address);

    // 初始counter应为0
    expect(await proxyWithLogicInterface.counter()).to.equal(0);

    // 通过代理调用increment
    await proxyWithLogicInterface.increment();

    // 验证counter是否加1
    expect(await proxyWithLogicInterface.counter()).to.equal(1);

    // 再次调用increment
    await proxyWithLogicInterface.increment();

    // 验证counter是否加到2
    expect(await proxyWithLogicInterface.counter()).to.equal(2);

    // 验证逻辑合约本身的counter没有变化（因为状态存储在代理中）
    expect(await logic1819.counter()).to.equal(0);
  });
});