// 断言库
const { expect } = require("chai");
// 与智能合约交互的hardhat库：部署合约、调用函数、获取签名账户等。
const { ethers } = require("hardhat");

describe("MyErcToken", function () {
  let myErcToken, MyErcToken, owner, addr1, addr2;
  const initialSupply = 1000000;

  // 钩子函数：在每个测试用例执行前运行一次，构建测试环境。
  beforeEach(async function () {
    // 获取签名用户
    [owner, addr1, addr2] = await ethers.getSigners();
    // 使用工厂创建合约实例
    MyErcToken = await ethers.getContractFactory("MyErcToken");
    // 部署合约并出示总供应量
    myErcToken = await MyErcToken.deploy(initialSupply);
  });

  it("部署后总供应量正确", async function () {
    const total = await myErcToken.totalSupply();
    const expectedTotalSupply = BigInt(initialSupply) * 10n ** 18n;
    expect(total).to.equal(expectedTotalSupply);
  });

  it("部署者初始余额正确", async function () {
    const balance = await myErcToken.balanceOf(owner.address);
    // expect(balance).to.equal(initialSupply * 10n ** 18n);
    const expectedBalance = BigInt(initialSupply) * 10n ** 18n;
    expect(balance).to.equal(expectedBalance);
  });

  it("转账功能正常", async function () {
    await myErcToken.transfer(addr1.address, 1000n);
    const balance = await myErcToken.balanceOf(addr1.address);
    expect(balance).to.equal(1000n);
  });

  it("余额不足转账失败", async function () {
    await expect(
      myErcToken.connect(addr1).transfer(owner.address, 1000n)
    ).to.be.revertedWith("transfer amount exceeds balance");
  });

  it("授权后transferFrom正常", async function () {
    await myErcToken.approve(addr1.address, 5000n);
    await myErcToken.connect(addr1).transferFrom(owner.address, addr2.address, 5000n);
    const balance = await myErcToken.balanceOf(addr2.address);
    expect(balance).to.equal(5000n);
  });

  it("授权额度不足时transferFrom失败", async function () {
    await myErcToken.approve(addr1.address, 1000n);
    await expect(
      myErcToken.connect(addr1).transferFrom(owner.address, addr2.address, 5000n)
    ).to.be.revertedWith("transfer amount exceeds allowance");
  });
});