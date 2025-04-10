import { ethers, Wallet, type Provider } from 'ethers'
import { createPublicClient, createWalletClient, defineChain, http } from 'viem'
import dotenv from 'dotenv'
import { privateKeyToAccount } from 'viem/accounts'

dotenv.config()

/**
 * 定义assetHubChain
 */
export const ASSET_HUB = 'https://westend-asset-hub-eth-rpc.polkadot.io'
export const assetHubChain = defineChain({
  id: 420420421,
  name: 'Asset-Hub Westend Testnet',
  network: 'Asset-Hub Westend Testnet',
  nativeCurrency: {
      name: 'WND',
      symbol: 'WND',
      decimals: 18,
  },
  rpcUrls: {
      default: {
          http: [ASSET_HUB],
      },
  },
  testnet: true,
})

/**
 * 获取ether client
 * @returns
 */
export function getEtherClient() {
  // Create a provider using the provider URL
  const provider = new ethers.JsonRpcProvider(ASSET_HUB);
  return provider;
}

/**
 * 设置ether wallet
 * @param provider
 * @returns
 */
export function getEtherWallet(provider: Provider) {
  const privateKey = process.env.PRIVATE_KEY;

  if (!privateKey) {
      throw new Error("Private key is not defined in the environment variables.");
  }

  // Create a wallet from the private key
  const wallet = new Wallet(privateKey, provider);

  // Log the wallet address
  console.log("Wallet Address:", wallet.address);

  return wallet;
}

/**
 * 获取viem公共客户端
 * @returns
 */
export async function getViemPublicClient() {
  const client = await createPublicClient({ chain: assetHubChain, transport: http(), })
  return client

}

/**
 * 获取viem钱包客户端
 * @returns 返回配置好的钱包客户端
 */
export async function getViemWalletClient() {
  const privateKey = process.env.PRIVATE_KEY
  if (privateKey === undefined) {
      throw new Error("private key not defined in env")
  }

  const privateKeyNoPrefix = privateKey.replace('0x', '');
  const account = privateKeyToAccount(`0x${privateKeyNoPrefix}`);
  const client = await createWalletClient({ account, chain: assetHubChain, transport: http(), })
  return client
}
