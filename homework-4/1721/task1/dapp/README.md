# dapp show how to use ethers and viem

- Ethers.js: https://docs.ethers.org/v6/
- Viem: https://viem.sh/

## 使用 Ethers.js 部署 Storage 合约

### 环境准备

1. 安装依赖
```bash
npm install
```

2. 配置环境变量
在项目根目录创建 `.env` 文件，添加以下内容：
```
PRIVATE_KEY=你的私钥
```

### Storage 合约说明

Storage 合约是一个简单的存储合约，提供两个主要功能：
- `store(uint256 num)`: 存储一个数值
- `retrieve()`: 读取存储的数值

合约代码位于 `src/storage.sol`。

### 部署步骤

1. 确保已经配置好环境变量中的私钥

2. 运行部署脚本
```bash
npm run storage:ethers
```

部署脚本会执行以下操作：
- 使用配置的私钥创建钱包实例
- 部署 Storage 合约
- 调用合约的 store 方法存储数值
- 调用合约的 retrieve 方法读取数值

### 部署成功输出示例

```
开始部署Storage合约...
Storage合约已部署到地址: 0x...
测试合约功能...
已存储数值: 42
读取到的数值: 42
```

### 注意事项

1. 确保私钥对应的账户有足够的测试币用于部署合约
2. 部署前确认网络连接正常
3. 请妥善保管私钥，不要泄露给他人

## 使用 Viem 部署 Storage 合约

### 环境准备

1. 安装依赖
```bash
npm install
```

2. 配置环境变量
在项目根目录创建 `.env` 文件，添加以下内容：
```
PRIVATE_KEY=你的私钥
```

### 部署步骤

1. 确保已经配置好环境变量中的私钥

2. 运行部署脚本
```bash
npm run storage:viem
```

部署脚本会执行以下操作：
- 创建公共客户端和钱包客户端实例
- 部署 Storage 合约
- 调用合约的 store 方法存储数值
- 调用合约的 retrieve 方法读取数值
- 监听新区块（持续5秒）

### 部署成功输出示例

```
开始部署Storage合约...
Storage合约已部署到地址: 0x...
测试合约功能...
已存储数值: 42
读取到的数值: 42
当前区块: 1234567
```
