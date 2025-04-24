1. 配置`.env`文件，添加以下内容：

   ```
   LOCAL_PRIV_KEY=你的私钥（不要泄露！）
   ```

2.安装依赖

```shell
npm install
```

3.编译合约

```shell
npx hardhat compile
```

4.运行脚本

```shell
node scripts/作业一/viem_main.js
node scripts/作业一/ethers_main.js
```
