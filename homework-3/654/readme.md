# 596号学生作业3：可升级代理合约实现

## 实现功能
1. 基础代理合约通过 `delegatecall` 调用逻辑合约
2. 管理员权限控制的合约升级功能
3. 存储一致性保障

## 测试步骤
1. 在Remix中部署 `LogicContract`
2. 部署 `UpgradeableProxy` 并传入逻辑合约地址
3. 通过代理合约调用 `increment()` 
4.

