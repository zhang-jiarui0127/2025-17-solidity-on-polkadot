import * as dotenv from "dotenv";
dotenv.config();

export const ALCHEMY_KEY = process.env.ALCHEMY_KEY!;
export const ALCHEMY_MAINNET_RPC = `https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_KEY}`;
export const ALCHEMY_SEPOLIA_RPC = `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_KEY}`;

export const DAI_ADDRESS = "0x6B175474E89094C44Da98b954EedeAC495271d0F";

export const CHAIN_IDS = {
  mainnet: 1,
  sepolia: 11155111,
  goerli: 5,
};

export const DAI_ADDRESSES = {
  mainnet: "0x6B175474E89094C44Da98b954EedeAC495271d0F",
  sepolia: "0x95b58a6Bff3D14B7DB2f5cb5F0Ad413DC2940658", // 这是一个常用测试 DAI
};

export const LINK_ADDRESSES = {
  mainnet: "0x.......",
  sepolia: "0x779877A7B0D9E8603169DdbD7836e478b4624789",
};