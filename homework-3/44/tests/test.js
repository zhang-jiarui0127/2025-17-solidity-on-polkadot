/* eslint-disable no-undef */
const { expect } = require("chai");
import { ethers } from 'ethers'

describe("Delegatecall Example", async function () {
    this.timeout(120000); // 网络太慢需要设置长点

    let logicContract;
    let proxyContract;
    let provider;

    beforeEach(async function () {
        const logicContractArtifactsPath = `browser/contracts/artifacts/LogicContract.json`;
        const logicContractMetadata = JSON.parse(await remix.call('fileManager', 'getFile', logicContractArtifactsPath));

        provider = new ethers.providers.Web3Provider(web3Provider);
        const signer = provider.getSigner(0);
        const logicContractFactory = new ethers.ContractFactory(logicContractMetadata.abi, logicContractMetadata.data.bytecode.object, signer);
        logicContract = await logicContractFactory.deploy();
        await logicContract.deployed();

        const proxyContractArtifactsPath = `browser/contracts/artifacts/ProxyContract.json`;
        const proxyContractMetadata = JSON.parse(await remix.call('fileManager', 'getFile', proxyContractArtifactsPath));
        const proxyContractFactory = new ethers.ContractFactory(proxyContractMetadata.abi, proxyContractMetadata.data.bytecode.object, signer);
        proxyContract = await proxyContractFactory.deploy(logicContract.address);
        await proxyContract.deployed();
    });

    it("Should increment the counter in the proxy contract", async function () {
        // 手动编码 counter 函数调用
        const counterSelector = ethers.utils.id("counter()").slice(0, 10);
        const incrementSelector = ethers.utils.id("increment()").slice(0, 10);

        // 获取代理合约计数器的初始值
        const initialCallData = {
            to: proxyContract.address,
            data: counterSelector
        };
        const initialCounterData = await provider.call(initialCallData);
        const initialCounter = ethers.BigNumber.from(initialCounterData).toNumber();

        // 调用代理合约的 increment 函数
        const signer = provider.getSigner(0);
        await signer.sendTransaction({
            to: proxyContract.address,
            data: incrementSelector
        });

        // 获取代理合约计数器的最终值
        const finalCallData = {
            to: proxyContract.address,
            data: counterSelector
        };
        const finalCounterData = await provider.call(finalCallData);
        const finalCounter = ethers.BigNumber.from(finalCounterData).toNumber();

        // 使用 expect 断言最终计数器的值是否等于初始值加 1
        expect(finalCounter).to.equal(initialCounter + 1);
    });
});