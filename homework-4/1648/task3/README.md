# Sample Hardhat Project

环境： macos M4-Max 64G

## 配置节点信息

编辑 `hardhat.config.ts` 文件，配置节点 `polkavm` 和 `ah` 信息。

## 启动substrate服务

参考文档
https://github.com/papermoonio/2025-17-solidity-on-polkadot/blob/main/homework-4/readme.md
在本地编译相关命令

```shell
# substrate-node
RUST_LOG="error,evm=debug,sc_rpc_server=info,runtime::revive=debug" target/release/substrate-node --dev --unsafe-rpc-external

# rpc
RUST_LOG="info,eth-rpc=debug" target/release/eth-rpc
```

## 设置环境变量

创建 `.env` 文件，配置 `RPC_URL` 和 `PRIVATE_KEY`

```shell
# polkavm 节点环境账户
LOCAL_PRIV_KEY=0x5fb92d6e98884f76de468fa3f6278f8807c48bebc13595d45af5bdc4da702133

# ah 节点环境账户（在本地利用 anvil 命令创建的账户密钥对，对应公钥是 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266）
AH_PRIV_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

## 合约测试

1. 安装依赖

```shell
npm install
```

2. 本地部署合约

使用 `hardhat.config.ts` 配置的本地节点 `polkavm`

### 编译合约为 polkavm 格式

```shell
npx hardhat compile-revive --contract Storage.sol --show-stack-traces
```

### 部署合约到 polkavm 节点

```shell
npx hardhat deploy-revive --contract Storage --network polkavm
```

3. 线上部署合约

```
npx hardhat deploy-revive --contract Storage --network ah
```

## 问题
