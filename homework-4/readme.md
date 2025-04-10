# Practice

- 作业 1: ethers viem 的使用
- 作业 2: Mini Dex 部署，熟悉算法
- 作业 3: Hardhat Revive 环境搭建

## 分别使用 ethers 和 viem 来部署合约，调用，侦听事件。使用 storage 合约即可。提交代码到 homework-4 目录

可以参考下面目录的代码片段。
https://github.com/papermoonio/2025-h1-solidity-polkadot-course/tree/master/lesson4/dapp

## 在 Remix 上部署 Mini Dex 到 Asset Hub，并与之交互。截屏即可

Mini Dex 代码
https://github.com/papermoonio/2025-h1-solidity-polkadot-course/blob/master/lesson4/hardhat-revive-ts/contracts/MiniDex.sol

Remix from polkadot
https://remix.polkadot.io/

## 搭建 hardhat 的本地环境，可以编译 Polkavm 代码，本地测试最简单的 Storage 合约。截屏即可

工程代码参考
https://github.com/papermoonio/2025-h1-solidity-polkadot-course/tree/master/lesson4/hardhat-revive-ts

本地服务

编译 resolc

```sh
git clone https://github.com/paritytech/revive
cd revive
make install-llvm
export LLVM_SYS_181_PREFIX=${PWD}/target-llvm/gnu/target-final
make install-bin
```

编译 polkadot-sdk

```bash
git clone https://github.com/paritytech/polkadot-sdk
cd polkadot-sdk

cargo build --release --bin substrate-node

cargo build --release -p pallet-revive-eth-rpc
```

运行

```bash
RUST_LOG="error,evm=debug,sc_rpc_server=info,runtime::revive=debug" target/release/substrate-node --dev --unsafe-rpc-external
```

```bash
RUST_LOG="info,eth-rpc=debug" target/release/eth-rpc
```
