# 工作原理说明
## 1.代理模式:

代理合约存储状态（counter变量）

逻辑合约包含业务逻辑（increment函数）

使用delegatecall调用逻辑合约的函数，但状态改变发生在代理合约的上下文中

delegatecall特性:

执行目标合约的代码

但使用调用合约的存储、余额和地址

这使得逻辑可升级，因为我们可以更换逻辑合约而保持状态不变

fallback函数:

当调用代理合约中不存在的函数时触发

使用内联汇编将调用转发到逻辑合约

保留返回值和错误处理

## 2.升级机制:

通过updateLogicContract可以更换逻辑合约地址

新逻辑合约必须与旧合约有兼容的存储布局

## 3.部署和使用步骤
首先部署LogicContract

使用LogicContract地址部署ProxyContract

所有调用都发送到ProxyContract地址

需要升级时，部署新的LogicContract并调用ProxyContract的updateLogicContract

这种模式是智能合约可升级性的基础，被广泛用于OpenZeppelin等库中的可升级合约实现。