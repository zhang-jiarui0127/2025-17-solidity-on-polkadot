import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";
import { MathLogic, MathLogicProxy } from "../typechain-types";

describe("MathLogic合约测试", function () {
    let mathLogic: MathLogic;
    let mathProxy: MathLogicProxy;
    let owner: any;
    let otherAccount: any;

    beforeEach(async function () {
        // 获取测试账户
        [owner, otherAccount] = await ethers.getSigners();

        // 部署逻辑合约
        const MathLogicFactory = await ethers.getContractFactory("MathLogic");
        mathLogic = await MathLogicFactory.deploy();

        // 部署代理合约
        const MathLogicProxyFactory = await ethers.getContractFactory("MathLogicProxy");
        mathProxy = await MathLogicProxyFactory.deploy(await mathLogic.getAddress());
    });

    describe("基础功能测试", function () {
        it("应该正确部署合约", async function () {
            console.log("mathProxy", await mathProxy.owner());
            console.log("mathLogic", await mathLogic.getAddress());
            expect(await mathProxy.owner()).to.equal(owner.address);
            expect(await mathProxy.logicContract()).to.equal(await mathLogic.getAddress());
        });

        it("应该正确设置初始值", async function () {
            console.log("mathProxy", await mathProxy.count());
            console.log("mathLogic", await mathLogic.count());
            expect(await mathProxy.count()).to.equal(100);
            expect(await mathLogic.count()).to.equal(1000);
        });
    });

    describe("代理模式和非代理模式测试", function () {
        it("delegatecall应该正确执行add操作", async function () {
            console.log("mathProxy 初始值: ", await mathProxy.count());
            console.log("mathLogic 初始值: ", await mathLogic.count());
            //使用delegatecall调用逻辑合约的add方法
            await mathProxy.add(5, 3, true);
            let proxyValue =  await mathProxy.getResult(true);
            let logicValue = await mathProxy.getResult(false);
            console.log("proxyValue", proxyValue);
            console.log("logicValue", logicValue);
           // 此时逻辑合约的result的值应该为1008
           expect(proxyValue).to.equal(108);  //因为代理合约的count值为100，add调用逻辑合约的add方法，count为当前合约的count=100，所以结果为108
           expect(logicValue).to.equal(0);
        });

        it("非delegatecall应该正确执行add操作", async function () {
            await mathProxy.add(5, 3, false);
            let proxyValue =  await mathProxy.getResult(true);
            let logicValue = await mathProxy.getResult(false);
            console.log("proxyValue", proxyValue);
            console.log("logicValue", logicValue);
            expect(proxyValue).to.equal(0);
            expect(logicValue).to.equal(1008);
        });

    });

});
