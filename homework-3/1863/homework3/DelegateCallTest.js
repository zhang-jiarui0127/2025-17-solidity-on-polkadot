const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DelegateCall测试", function () {
  let logicContract;
  let proxyContract;
  let owner;

  beforeEach(async function () {
    [owner] = await ethers.getSigners();
    
    // 部署逻辑合约
    const LogicContract = await ethers.getContractFactory("LogicContract");
    logicContract = await LogicContract.deploy();
    await logicContract.deployed();
    
    // 部署代理合约
    const ProxyContract = await ethers.getContractFactory("ProxyContract");
    proxyContract = await ProxyContract.deploy(logicContract.address);
    await proxyContract.deployed();
  });

  it("应该通过delegatecall增加计数器并保留在代理合约中", async function () {
    // 检查初始值
    expect(await proxyContract.counter()).to.equal(0);
    
    // 通过代理合约调用increment函数
    await proxyContract.increment();
    
    // 验证代理合约中的counter已增加
    expect(await proxyContract.counter()).to.equal(1);
    
    // 验证逻辑合约中的counter保持不变
    // (因为delegatecall只使用逻辑合约的代码，但状态更改发生在代理合约中)
    expect(await logicContract.counter()).to.equal(0);
    
    // 再次调用increment
    await proxyContract.increment();
    
    // 验证代理合约中的counter再次增加
    expect(await proxyContract.counter()).to.equal(2);
  });
}); 