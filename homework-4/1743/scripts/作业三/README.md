### 首先启动本地，先确认 hardhat.config.js 配置文件里面的 nodeBinaryPath 和 adapterBinaryPath 配置你本机的安装地址

```shell
USE_RESOLC=true npx hardhat node-polkavm
```

### 在开一个终端，运行命令

```shell
USE_RESOLC=true npx hardhat run ./scripts/作业三/storage.js --network localNode
```
