import { ethers } from "ethers";
import * as dotenv from "dotenv";
dotenv.config();

import { DAI_ADDRESSES } from './config';

const dai_address = DAI_ADDRESSES['mainnet'];

import { daiAbi } from './abi';

async function main() {
  const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
  const dai = new ethers.Contract(dai_address, daiAbi, provider);

  const name = await dai.name();
  const symbol = await dai.symbol();
  const decimals = await dai.decimals();
  const balance = await dai.balanceOf("0x000000000000000000000000000000000000dEaD"); // DAI blackhole address

  console.log(`代币名称: ${name}`);
  console.log(`代币符号: ${symbol}`);
  console.log(`精度: ${decimals}`);
  console.log(`0x...dEaD 地址的余额: ${ethers.formatUnits(balance, decimals)} ${symbol}`);
}

main().catch(console.error);