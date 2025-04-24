// 简化版部署和测试DEX合约的脚本 - 只使用部署者账户
const { ethers } = require("hardhat");

async function main() {
  console.log("开始部署和测试DEX合约（简化版）...");

  // 检查ethers版本并适配API
  console.log(`Ethers.js版本: ${ethers.version || "未知"}`);
  // 根据ethers版本确定parseEther函数
  const parseEther = ethers.utils?.parseEther || ethers.parseEther;
  const formatEther = ethers.utils?.formatEther || ethers.formatEther;

  if (!parseEther || !formatEther) {
    console.error("无法确定parseEther/formatEther函数，请检查ethers.js版本");
    return;
  }

  // 获取部署者账户
  const [deployer] = await ethers.getSigners();
  console.log(`部署账户: ${deployer.address}`);

  // 获取余额
  let deployerBalance;
  try {
    deployerBalance = await ethers.provider.getBalance(deployer.address);
  } catch (error) {
    try {
      deployerBalance = await deployer.getBalance();
    } catch (innerError) {
      console.log("无法获取账户余额");
      deployerBalance = ethers.BigNumber ? ethers.BigNumber.from("0") : 0n;
    }
  }
  console.log(`账户余额: ${formatEther(deployerBalance)}`);

  // 部署选项
  const deployOptions = {
    gasLimit: 3000000,
    gasPrice: ethers.utils?.parseUnits
      ? ethers.utils.parseUnits("10", "gwei")
      : ethers.parseUnits?.("10", "gwei"),
  };

  try {
    // 部署TokenA
    console.log("正在部署TokenA...");
    const SimpleERC20 = await ethers.getContractFactory("SimpleERC20");
    const tokenA = await SimpleERC20.deploy(
      "TokenA",
      "TKA",
      18,
      100, // 较小的初始供应量，足够测试
      deployOptions
    );

    console.log(
      `TokenA 部署交易哈希: ${
        tokenA.hash || tokenA.deployTransaction?.hash || "未获取到交易哈希"
      }`
    );

    // 等待部署完成
    console.log("等待TokenA部署完成...");
    if (tokenA.deployed) {
      await tokenA.deployed();
    } else if (tokenA.waitForDeployment) {
      await tokenA.waitForDeployment();
    } else {
      console.log("等待15秒...");
      await new Promise((resolve) => setTimeout(resolve, 15000));
    }

    const tokenAAddress = tokenA.address || (await tokenA.getAddress?.());
    console.log(`TokenA 部署成功: ${tokenAAddress}`);

    // 部署TokenB
    console.log("正在部署TokenB...");
    const tokenB = await SimpleERC20.deploy(
      "TokenB",
      "TKB",
      18,
      100, // 较小的初始供应量，足够测试
      deployOptions
    );

    console.log(
      `TokenB 部署交易哈希: ${
        tokenB.hash || tokenB.deployTransaction?.hash || "未获取到交易哈希"
      }`
    );

    console.log("等待TokenB部署完成...");
    if (tokenB.deployed) {
      await tokenB.deployed();
    } else if (tokenB.waitForDeployment) {
      await tokenB.waitForDeployment();
    } else {
      console.log("等待15秒...");
      await new Promise((resolve) => setTimeout(resolve, 15000));
    }

    const tokenBAddress = tokenB.address || (await tokenB.getAddress?.());
    console.log(`TokenB 部署成功: ${tokenBAddress}`);

    // 部署DEX合约
    console.log("正在部署DEX合约...");
    const MinimalDEX = await ethers.getContractFactory("MinimalDEX");
    const dex = await MinimalDEX.deploy(
      tokenAAddress,
      tokenBAddress,
      deployOptions
    );

    console.log(
      `DEX 部署交易哈希: ${
        dex.hash || dex.deployTransaction?.hash || "未获取到交易哈希"
      }`
    );

    console.log("等待DEX部署完成...");
    if (dex.deployed) {
      await dex.deployed();
    } else if (dex.waitForDeployment) {
      await dex.waitForDeployment();
    } else {
      console.log("等待15秒...");
      await new Promise((resolve) => setTimeout(resolve, 15000));
    }

    const dexAddress = dex.address || (await dex.getAddress?.());
    console.log(`DEX 部署成功: ${dexAddress}`);

    // 测试流动性添加
    console.log("\n========== 开始测试添加流动性 ==========");

    // 检查合约接口是否正常
    console.log("验证合约接口...");
    try {
      const reserveA = await dex.reserveA();
      const reserveB = await dex.reserveB();
      console.log(
        `初始储备金 - TokenA: ${formatEther(reserveA)}, TokenB: ${formatEther(
          reserveB
        )}`
      );
    } catch (error) {
      console.error("无法读取储备金，合约可能有问题:", error.message);
      return;
    }

    // 检查部署者代币余额
    const balanceA = await tokenA.balanceOf(deployer.address);
    const balanceB = await tokenB.balanceOf(deployer.address);
    console.log(
      `部署者代币余额 - TokenA: ${formatEther(balanceA)}, TokenB: ${formatEther(
        balanceB
      )}`
    );

    // 使用较小数量测试授权和添加流动性
    const amountA = parseEther("1");
    const amountB = parseEther("2");

    console.log(`\n正在授权DEX合约使用 ${formatEther(amountA)} TokenA...`);
    const approveTxA = await tokenA.approve(dexAddress, amountA, {
      gasLimit: 200000,
      gasPrice: ethers.utils?.parseUnits
        ? ethers.utils.parseUnits("10", "gwei")
        : ethers.parseUnits?.("10", "gwei"),
    });
    console.log(`TokenA授权交易哈希: ${approveTxA.hash}`);

    // 提示用户检查交易
    console.log(
      `请在区块浏览器中检查交易状态: https://sepolia.lineascan.build/tx/${approveTxA.hash}`
    );
    console.log("等待TokenA授权确认（120秒）...");
    try {
      const receiptA = await approveTxA.wait(1);
      console.log(
        `TokenA授权交易确认，状态: ${receiptA.status === 1 ? "成功" : "失败"}`
      );
    } catch (error) {
      console.log("TokenA授权等待超时，但继续执行");
    }

    // 等待5秒，确保交易被网络处理
    console.log("等待5秒...");
    await new Promise((resolve) => setTimeout(resolve, 5000));

    // 检查授权结果
    const allowanceA = await tokenA.allowance(deployer.address, dexAddress);
    console.log(`TokenA授权结果: ${formatEther(allowanceA)}`);

    if (allowanceA.toString() === "0") {
      console.log("TokenA授权失败或未确认，稍等后再次检查");
      // 再次等待10秒
      await new Promise((resolve) => setTimeout(resolve, 10000));
      const newAllowanceA = await tokenA.allowance(
        deployer.address,
        dexAddress
      );
      console.log(`TokenA再次检查授权结果: ${formatEther(newAllowanceA)}`);

      if (newAllowanceA.toString() === "0") {
        console.log("TokenA授权仍未成功，流程无法继续");
        return;
      }
    }

    console.log(`\n正在授权DEX合约使用 ${formatEther(amountB)} TokenB...`);
    const approveTxB = await tokenB.approve(dexAddress, amountB, {
      gasLimit: 200000,
      gasPrice: ethers.utils?.parseUnits
        ? ethers.utils.parseUnits("10", "gwei")
        : ethers.parseUnits?.("10", "gwei"),
    });
    console.log(`TokenB授权交易哈希: ${approveTxB.hash}`);

    console.log(
      `请在区块浏览器中检查交易状态: https://sepolia.lineascan.build/tx/${approveTxB.hash}`
    );
    console.log("等待TokenB授权确认（120秒）...");
    try {
      const receiptB = await approveTxB.wait(1);
      console.log(
        `TokenB授权交易确认，状态: ${receiptB.status === 1 ? "成功" : "失败"}`
      );
    } catch (error) {
      console.log("TokenB授权等待超时，但继续执行");
    }

    // 等待5秒，确保交易被网络处理
    console.log("等待5秒...");
    await new Promise((resolve) => setTimeout(resolve, 5000));

    // 检查授权结果
    const allowanceB = await tokenB.allowance(deployer.address, dexAddress);
    console.log(`TokenB授权结果: ${formatEther(allowanceB)}`);

    if (allowanceB.toString() === "0") {
      console.log("TokenB授权失败或未确认，稍等后再次检查");
      // 再次等待10秒
      await new Promise((resolve) => setTimeout(resolve, 10000));
      const newAllowanceB = await tokenB.allowance(
        deployer.address,
        dexAddress
      );
      console.log(`TokenB再次检查授权结果: ${formatEther(newAllowanceB)}`);

      if (newAllowanceB.toString() === "0") {
        console.log("TokenB授权仍未成功，流程无法继续");
        return;
      }
    }

    // 添加流动性
    console.log(
      `\n尝试添加流动性: ${formatEther(amountA)} TokenA 和 ${formatEther(
        amountB
      )} TokenB`
    );
    const addLiquidityTx = await dex.addLiquidity(amountA, amountB, {
      gasLimit: 1000000, // 给予充足的gas
      gasPrice: ethers.utils?.parseUnits
        ? ethers.utils.parseUnits("10", "gwei")
        : ethers.parseUnits?.("10", "gwei"),
    });
    console.log(`添加流动性交易哈希: ${addLiquidityTx.hash}`);

    console.log(
      `请在区块浏览器中检查交易状态: https://sepolia.lineascan.build/tx/${addLiquidityTx.hash}`
    );
    console.log("等待添加流动性交易确认（120秒）...");
    try {
      const receipt = await addLiquidityTx.wait(1);
      console.log(
        `添加流动性交易确认，状态: ${receipt.status === 1 ? "成功" : "失败"}`
      );
    } catch (error) {
      console.log("添加流动性等待超时，但继续检查结果");
    }

    // 等待10秒，确保交易被网络处理
    console.log("等待10秒...");
    await new Promise((resolve) => setTimeout(resolve, 10000));

    // 检查储备金是否更新
    const newReserveA = await dex.reserveA();
    const newReserveB = await dex.reserveB();
    console.log(
      `\n当前储备金 - TokenA: ${formatEther(
        newReserveA
      )}, TokenB: ${formatEther(newReserveB)}`
    );

    if (newReserveA.toString() === "0" && newReserveB.toString() === "0") {
      console.log("警告: 储备金仍为0，流动性添加可能失败");

      // 检查DEX合约的代币余额
      const dexBalanceA = await tokenA.balanceOf(dexAddress);
      const dexBalanceB = await tokenB.balanceOf(dexAddress);
      console.log(
        `DEX合约代币余额 - TokenA: ${formatEther(
          dexBalanceA
        )}, TokenB: ${formatEther(dexBalanceB)}`
      );

      // 检查部署者的LP代币余额
      try {
        const lpBalance = await dex.balanceOf(deployer.address);
        console.log(`部署者LP代币余额: ${lpBalance.toString()}`);
      } catch (error) {
        console.log("无法查询LP代币余额:", error.message);
      }
    } else {
      console.log("流动性添加成功!");
      console.log(
        `当前价格比率: 1 TokenA = ${
          formatEther(newReserveB) / formatEther(newReserveA)
        } TokenB`
      );

      // 检查部署者的LP代币余额
      const lpBalance = await dex.balanceOf(deployer.address);
      console.log(`部署者LP代币余额: ${lpBalance.toString()}`);
    }

    // 输出合约地址汇总
    console.log("\n========== 合约地址汇总 ==========");
    console.log(`TokenA: ${tokenAAddress}`);
    console.log(`TokenB: ${tokenBAddress}`);
    console.log(`DEX: ${dexAddress}`);
    console.log(
      "在Linea Sepolia区块浏览器上可查看详情: https://sepolia.lineascan.build/"
    );
  } catch (error) {
    console.error("执行过程中出错:");
    console.error(error);

    // 输出交易哈希，如果有的话
    if (error.transaction) {
      console.log(
        `可通过 https://sepolia.lineascan.build/tx/${error.transaction} 查看交易状态`
      );
    }
  }
}

// 运行主函数
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("运行出错:", error);
    process.exit(1);
  });
