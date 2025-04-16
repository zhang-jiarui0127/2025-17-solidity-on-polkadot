// 测试脚本示例，适用于Hardhat或Truffle环境
// 使用方法：npx hardhat test

const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ProxyContract with DelegateCall", function () {
  let logicContract;
  let proxyContract;
  let owner;
  let user;

  beforeEach(async function () {
    // 获取账户
    [owner, user] = await ethers.getSigners();

    // 部署逻辑合约
    const LogicContract = await ethers.getContractFactory("LogicContract");
    logicContract = await LogicContract.deploy();
    await logicContract.deployed();
    console.log("逻辑合约部署地址:", logicContract.address);

    // 部署代理合约，并设置逻辑合约地址
    const ProxyContract = await ethers.getContractFactory("ProxyContract");
    proxyContract = await ProxyContract.deploy(logicContract.address);
    await proxyContract.deployed();
    console.log("代理合约部署地址:", proxyContract.address);
  });

  it("初始状态检查", async function () {
    // 检查初始值应该为0
    expect(await proxyContract.value()).to.equal(0);
    
    // 检查初始owner应该是部署账户
    expect(await proxyContract.owner()).to.equal(owner.address);
    
    // 检查逻辑合约地址是否正确设置
    expect(await proxyContract.logicContractAddress()).to.equal(logicContract.address);
  });

  it("通过代理合约增加value值", async function () {
    // 首先检查初始值
    expect(await proxyContract.value()).to.equal(0);
    
    // 调用increment函数
    const tx = await proxyContract.increment();
    await tx.wait();
    
    // 检查更新后的值是否为1
    expect(await proxyContract.value()).to.equal(1);
    
    // 再次调用increment
    const tx2 = await proxyContract.increment();
    await tx2.wait();
    
    // 检查更新后的值是否为2
    expect(await proxyContract.value()).to.equal(2);
  });

  it("通过代理合约设置value值", async function () {
    // 设置为指定值
    const newValue = 100;
    const tx = await proxyContract.setValue(newValue);
    await tx.wait();
    
    // 检查更新后的值
    expect(await proxyContract.value()).to.equal(newValue);
  });

  it("验证状态变更只发生在代理合约", async function () {
    // 通过代理合约设置value
    const newValue = 50;
    await proxyContract.setValue(newValue);
    
    // 验证代理合约的value已更新
    expect(await proxyContract.value()).to.equal(newValue);
    
    // 验证逻辑合约的value保持不变（应为0或部署时的初始值）
    expect(await logicContract.value()).to.equal(0);
  });

  it("验证使用不同账户调用", async function () {
    // 使用另一个账户调用代理合约
    const userProxy = proxyContract.connect(user);
    
    // 调用increment函数
    await userProxy.increment();
    
    // 检查更新后的值
    expect(await proxyContract.value()).to.equal(1);
    
    // 检查owner不变
    expect(await proxyContract.owner()).to.equal(owner.address);
  });
}); 