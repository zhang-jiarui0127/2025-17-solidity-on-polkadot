const { expect } = require("chai");

describe("Proxy with Delegatecall", function () {
  let Logic, Proxy, logic, proxy;

  beforeEach(async function () {
    // 获取合约工厂
    Logic = await ethers.getContractFactory("Logic");
    Proxy = await ethers.getContractFactory("Proxy");
    
    // 部署逻辑合约
    logic = await Logic.deploy();
    await logic.deployed();
    
    // 部署代理合约并传入逻辑合约地址
    proxy = await Proxy.deploy(logic.address);
    await proxy.deployed();
  });

  it("should increment counter in proxy using delegatecall", async function () {
    // 检查初始值
    expect(await proxy.counter()).to.equal(0);
    
    // 调用increment函数
    await proxy.increment();
    expect(await proxy.counter()).to.equal(1);
    
    // 再次调用并验证
    await proxy.increment();
    expect(await proxy.counter()).to.equal(2);
    
    // 验证逻辑合约的counter未改变
    expect(await logic.counter()).to.equal(0);
  });
});