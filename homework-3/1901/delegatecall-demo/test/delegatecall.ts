import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { getAddress } from "viem";

describe("Delegatecall Proxy Test", function () {
  async function deployFixture() {
    const [owner, other] = await hre.viem.getWalletClients();
    const publicClient = await hre.viem.getPublicClient();

    // 部署 Logic 合约
    const logic = await hre.viem.deployContract("Logic", []);

    // 部署 Proxy 合约，传入 logic 地址
    const proxy = await hre.viem.deployContract("Proxy", [logic.address]);

    // 用 Logic ABI 读取 Proxy 的状态（delegatecall 需要用 Logic 的 ABI 操作）
    const proxyAsLogic = await hre.viem.getContractAt("Logic", proxy.address);

    return {
      owner,
      other,
      logic,
      proxy,
      proxyAsLogic,
      publicClient,
    };
  }

  describe("Deployment", function () {
    it("Should initialize proxy and logic", async function () {
      const { proxy, logic } = await loadFixture(deployFixture);
      expect(typeof proxy.address).to.equal("string");
      expect(proxy.address.length).to.be.greaterThan(0);
      expect(typeof logic.address).to.equal("string");
      expect(logic.address.length).to.be.greaterThan(0);
    });

    it("Should start with counter == 0", async function () {
      const { proxyAsLogic } = await loadFixture(deployFixture);
      expect(await proxyAsLogic.read.counter()).to.equal(0n);
    });
  });

  describe("Delegatecall increment()", function () {
    it("Should increase counter via delegatecall", async function () {
      const { proxy, proxyAsLogic } = await loadFixture(deployFixture);

      // 读取原始 counter 值
      expect(await proxyAsLogic.read.counter()).to.equal(0n);

      // 执行 delegatecall 增加计数器
      const hash = await proxy.write.delegateIncrement();
      const publicClient = await hre.viem.getPublicClient();
      await publicClient.waitForTransactionReceipt({ hash });

      // 读取新值
      const updated = await proxyAsLogic.read.counter();
      expect(updated).to.equal(1n);
    });

    it("Should increment multiple times", async function () {
      const { proxy, proxyAsLogic } = await loadFixture(deployFixture);

      for (let i = 1; i <= 3; i++) {
        const hash = await proxy.write.delegateIncrement();
        const publicClient = await hre.viem.getPublicClient();
        await publicClient.waitForTransactionReceipt({ hash });

        const count = await proxyAsLogic.read.counter();
        expect(count).to.equal(BigInt(i));
      }
    });
  });
});