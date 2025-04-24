// 测试DEX合约的代币兑换功能
const { ethers } = require("hardhat");

async function main() {
  console.log("开始测试DEX合约的代币兑换功能...");

  // 适配ethers不同版本的API
  const parseEther = ethers.utils?.parseEther || ethers.parseEther;
  const formatEther = ethers.utils?.formatEther || ethers.formatEther;

  if (!parseEther || !formatEther) {
    console.error("无法确定parseEther/formatEther函数，请检查ethers.js版本");
    return;
  }

  // 获取部署者账户
  const [deployer] = await ethers.getSigners();
  console.log(`测试账户: ${deployer.address}`);

  try {
    // 使用正确的合约地址 - 之前部署成功的地址
    const tokenAAddress = "0xea54e061E82a14b21d14AF3891c86026D6EA4A50";
    const tokenBAddress = "0xC1bed3FE246eD0A4D4D6cF97f225aFF8435dfcA4";
    const dexAddress = "0x57D386359b2364435C346Ee7d118Cf265C8C6CAE";

    console.log(`连接到TokenA合约: ${tokenAAddress}`);
    // 使用替代方法连接合约
    const SimpleERC20 = await ethers.getContractFactory("SimpleERC20");
    const tokenA = await new ethers.Contract(
      tokenAAddress,
      SimpleERC20.interface,
      deployer
    );

    console.log(`连接到TokenB合约: ${tokenBAddress}`);
    const tokenB = await new ethers.Contract(
      tokenBAddress,
      SimpleERC20.interface,
      deployer
    );

    console.log(`连接到DEX合约: ${dexAddress}`);
    const MinimalDEX = await ethers.getContractFactory("MinimalDEX");
    const dex = await new ethers.Contract(
      dexAddress,
      MinimalDEX.interface,
      deployer
    );

    // 检查当前DEX状态
    console.log("\n========== 交换前状态 ==========");
    const reserveA1 = await dex.reserveA();
    const reserveB1 = await dex.reserveB();
    console.log(
      `DEX储备金 - TokenA: ${formatEther(reserveA1)}, TokenB: ${formatEther(
        reserveB1
      )}`
    );
    console.log(
      `当前价格比率: 1 TokenA = ${
        formatEther(reserveB1) / formatEther(reserveA1)
      } TokenB`
    );

    // 检查用户余额
    const balanceA1 = await tokenA.balanceOf(deployer.address);
    const balanceB1 = await tokenB.balanceOf(deployer.address);
    console.log(
      `用户余额 - TokenA: ${formatEther(balanceA1)}, TokenB: ${formatEther(
        balanceB1
      )}`
    );

    // LP代币总供应量
    const totalSupply1 = await dex.totalSupply();
    console.log(`LP代币总供应量: ${formatEther(totalSupply1)}`);

    // 用户LP代币余额
    const lpBalance1 = await dex.balanceOf(deployer.address);
    console.log(`用户LP代币余额: ${formatEther(lpBalance1)}`);

    // 执行代币交换 - 使用TokenA换取TokenB
    console.log("\n========== 执行代币交换 ==========");

    // 使用0.1个TokenA交换TokenB
    const swapAmount = parseEther("0.1");
    console.log(`将使用 ${formatEther(swapAmount)} TokenA 兑换 TokenB`);

    // 计算预期可获得的TokenB数量
    const fee = swapAmount.mul
      ? swapAmount.mul(3).div(1000)
      : (swapAmount * 3n) / 1000n; // 0.3%手续费
    const amountInAfterFee = swapAmount.sub
      ? swapAmount.sub(fee)
      : swapAmount - fee;

    let expectedOut;
    if (reserveB1.mul) {
      expectedOut = amountInAfterFee
        .mul(reserveB1)
        .div(reserveA1.add(amountInAfterFee));
    } else {
      expectedOut =
        (amountInAfterFee * reserveB1) / (reserveA1 + amountInAfterFee);
    }

    console.log(`预期可获得约 ${formatEther(expectedOut)} TokenB`);

    // 授权DEX使用TokenA
    console.log("授权DEX合约使用TokenA...");
    const approveTx = await tokenA.approve(dexAddress, swapAmount, {
      gasLimit: 200000,
      gasPrice: ethers.utils?.parseUnits
        ? ethers.utils.parseUnits("10", "gwei")
        : ethers.parseUnits?.("10", "gwei"),
    });

    console.log(`授权交易哈希: ${approveTx.hash}`);
    console.log("等待授权交易确认...");
    try {
      const receiptA = await approveTx.wait(1);
      console.log(
        `授权交易确认，状态: ${receiptA.status === 1 ? "成功" : "失败"}`
      );
    } catch (error) {
      console.log("授权等待超时，但继续执行");
    }

    // 执行代币交换
    console.log(`\n执行代币交换: ${formatEther(swapAmount)} TokenA -> TokenB`);
    const swapTx = await dex.swap(tokenAAddress, swapAmount, {
      gasLimit: 1000000,
      gasPrice: ethers.utils?.parseUnits
        ? ethers.utils.parseUnits("10", "gwei")
        : ethers.parseUnits?.("10", "gwei"),
    });

    console.log(`交换交易哈希: ${swapTx.hash}`);
    console.log(
      `请查看交易状态: https://sepolia.lineascan.build/tx/${swapTx.hash}`
    );
    console.log("等待交换交易确认...");

    try {
      const receiptSwap = await swapTx.wait(1);
      console.log(
        `交换交易确认，状态: ${receiptSwap.status === 1 ? "成功" : "失败"}`
      );
    } catch (error) {
      console.log("交换交易等待超时，但继续检查结果");
    }

    // 等待10秒确保交易完成
    console.log("等待10秒...");
    await new Promise((resolve) => setTimeout(resolve, 10000));

    // 检查交换后的状态
    console.log("\n========== 交换后状态 ==========");
    const reserveA2 = await dex.reserveA();
    const reserveB2 = await dex.reserveB();
    console.log(
      `DEX储备金 - TokenA: ${formatEther(reserveA2)}, TokenB: ${formatEther(
        reserveB2
      )}`
    );
    console.log(
      `当前价格比率: 1 TokenA = ${
        formatEther(reserveB2) / formatEther(reserveA2)
      } TokenB`
    );

    // 检查用户余额
    const balanceA2 = await tokenA.balanceOf(deployer.address);
    const balanceB2 = await tokenB.balanceOf(deployer.address);
    console.log(
      `用户余额 - TokenA: ${formatEther(balanceA2)}, TokenB: ${formatEther(
        balanceB2
      )}`
    );

    // LP代币总供应量
    const totalSupply2 = await dex.totalSupply();
    console.log(`LP代币总供应量: ${formatEther(totalSupply2)}`);

    // 用户LP代币余额
    const lpBalance2 = await dex.balanceOf(deployer.address);
    console.log(`用户LP代币余额: ${formatEther(lpBalance2)}`);

    console.log("\n交易完成! 可以在区块浏览器上查看更多详情");
  } catch (error) {
    console.error("执行过程中出错:");
    console.error(error);

    if (error.transaction) {
      console.log(`交易哈希: ${error.transaction}`);
      console.log(
        `可在区块浏览器查看: https://sepolia.lineascan.build/tx/${error.transaction}`
      );
    }
  }
}

// 运行主函数
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("脚本执行失败:", error);
    process.exit(1);
  });
