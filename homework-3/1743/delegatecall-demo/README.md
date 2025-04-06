# 代理合约测试步骤

```shell
# 安装依赖
npm install
# 编译合约
npx hardhat compile-revive --contract LogicContract.sol
npx hardhat compile-revive --contract ProxyContract.sol
# 运行测试
npx hardhat test test/proxy-test.js --network ah
```
