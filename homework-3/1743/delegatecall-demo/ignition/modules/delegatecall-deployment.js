const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("DelegatecallDeployment", (m) => {
  // 部署逻辑合约
  const logicContract = m.contract("LogicContract");

  // 部署代理合约，并将逻辑合约地址作为构造函数参数
  const proxyContract = m.contract("ProxyContract", [logicContract]);

  // 初始化代理合约
  const initializeProxy = m.call(proxyContract, "initialize", [], {
    id: "initialize_proxy",
    // 确保在代理合约部署后执行初始化
    after: [proxyContract],
  });

  // 调用代理合约的increment函数以测试功能
  const incrementCall = m.call(proxyContract, "increment", [], {
    id: "test_increment",
    // 确保在初始化之后执行
    after: [initializeProxy],
  });

  // 返回部署的合约，这些合约将可以通过ctx.contracts在afterAll中访问
  return { logicContract, proxyContract };
});
