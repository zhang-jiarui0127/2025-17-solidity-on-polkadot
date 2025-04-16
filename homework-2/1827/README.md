# ERC20 代币合约实现

这是一个从零开始实现的符合ERC20标准的代币合约，不依赖任何外部库。

## 文件结构

- `IERC20.sol` - ERC20标准接口定义
- `MyToken.sol` - ERC20代币合约实现

## 合约特性

- 完全符合ERC20标准
- 实现了基本的代币功能：转账、授权、查询余额等
- 包含可选的扩展功能：增加/减少授权额度
- 支持代币名称、符号和精度定义
- 内部铸造和销毁功能

## 如何使用

### 部署合约

1. 准备[remix网站](https://remix.polkadot.io/)：
2. 将本目录下的`IERC20.sol`和`MyToken.sol`复制进去
3. 编译部署合约

### 合约参数

部署时需要提供以下参数：

- `name_`：代币名称，如 "My ERC20 Token"
- `symbol_`：代币符号，如 "MET"
- `decimals_`：代币精度，通常为18
- `initialSupply_`：初始代币供应量

### 主要功能

- `transfer(address recipient, uint256 amount)` - 转移代币到指定地址
- `approve(address spender, uint256 amount)` - 授权指定地址可以使用的代币数量
- `transferFrom(address sender, address recipient, uint256 amount)` - 代表其他地址转移代币
- `balanceOf(address account)` - 查询地址余额
- `allowance(address owner, address spender)` - 查询授权额度
- `totalSupply()` - 查询代币总供应量

## 扩展功能

- `increaseAllowance(address spender, uint256 addedValue)` - 增加授权额度
- `decreaseAllowance(address spender, uint256 subtractedValue)` - 减少授权额度