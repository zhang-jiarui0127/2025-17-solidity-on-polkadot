# delegatecall 实践案例

本项目实现了一个简单的代理模式示例，展示如何使用 `delegatecall` 来执行逻辑合约的函数，同时保留调用者的状态。

## 项目结构

- `LogicContract.sol` - 逻辑合约，包含增加计数器的功能
- `ProxyContract.sol` - 代理合约，通过delegatecall调用逻辑合约
- `test.js` - 测试脚本，验证代理合约的功能

## delegatecall 原理

`delegatecall` 是 Solidity 提供的一种底层调用方式，它有以下特点：

1. 执行的是目标合约的代码
2. 但使用的是调用合约的存储、地址和余额
3. 调用者的上下文(context)被保留

这使得 `delegatecall` 非常适用于实现可升级合约和代理模式。

## 合约设计

### LogicContract

逻辑合约定义了一个简单的计数功能：

- `increment()`: 将 value 值加 1
- `setValue(uint256)`: 设置 value 为指定值
- `getValue()`: 获取当前 value 值

### ProxyContract

代理合约通过 delegatecall 调用逻辑合约：

- 存储了逻辑合约的地址
- 通过 delegatecall 调用逻辑合约的函数
- 提供了便捷方法调用逻辑合约的 increment() 和 setValue() 函数

## 重要概念

1. **存储布局一致性**: 代理合约和逻辑合约的状态变量布局必须一致，否则会导致异常行为
2. **执行环境**: delegatecall执行的是逻辑合约的代码，但在代理合约的环境中
3. **状态保存**: 所有状态变更都保存在代理合约中，逻辑合约不受影响

## 如何测试

打开[remix网站](https://remix.polkadot.io/)

1. 编译部署逻辑合约
2. 编译部署代理合约，将逻辑合约的合约地址填入代理合约的构造器中

3. 测试：调用代理合约的increment等，在代理合约中可以看到value值的变化

## 运行测试后的预期结果

- 初始状态: 代理合约的 value 为 0, owner 为部署者
- 调用 increment 后: 代理合约的 value 增加到 1, 再次调用增加到 2
- 调用 setValue 后: 代理合约的 value 被设置为指定值
- 代理合约的状态变更不会影响逻辑合约的状态

## 实际应用场景

这种模式在以下场景非常有用:

- 合约升级: 可以替换逻辑合约而保留状态
- 代码重用: 多个代理合约可以共享同一个逻辑合约
- 节省gas: 减少部署完整合约的成本