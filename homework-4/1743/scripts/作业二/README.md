说明：因为 codesize 的问题，所以部署在 evm 的 LINEA_SEPOLIA 测试网上。

将 Dex_in_one.sol 合约 copy 到 contracts 下面,因为是在 evm 测试链下面运行，所以版本高一点,用的 hardhat config 文件是：
hardhat.solc.config.js

1. 配置`.env`文件，添加以下内容：

   ```
   LINEA_SEPOLIA_RPC_URL=https://rpc.sepolia.linea.build
   LOCAL_PRIV_KEY=你的私钥（不要泄露！）
   LINEA_API_KEY=你的Linea区块浏览器API密钥（可选，用于验证合约）
   ```

2. 运行部署脚本获取 token 和 dex 的地址

   ```
   npx hardhat run scripts/作业二/deploy_simple.js --config hardhat.solc.config.js --network lineaSepolia
   ```

3. 测试交换，将步骤二中输出的 TokenA 、TokenB、DEX 地址填入 swap_test.js 中，然后运行 swap_test.js

```
 npx hardhat run scripts/作业二/swap_test.js --config hardhat.solc.config.js --network lineaSepolia
```
