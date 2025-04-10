import { Contract, ethers } from 'ethers';
import type { Account, Hex, PublicClient, WalletClient } from 'viem';

/**
 * 使用ethers部署合约
 * @param abi
 * @param bytecode
 * @param wallet
 * @returns
 */
export async function deployContractByEthers(
  abi: any[],
  bytecode: string,
  wallet: ethers.Wallet,
) {
  const factory = new ethers.ContractFactory(abi, bytecode, wallet);
  const contract = await factory.deploy();
  await contract.waitForDeployment();
  const contractAddress = contract.target.toString();
  return contractAddress;
}

/**
 * 使用viem部署合约
 * @param abi
 * @param bytecode
 * @param wallet
 * @returns
 */
export async function deployContractByViem(
  abi: any[],
  bytecode: Hex,
  publicClient: PublicClient,
  walleClient: WalletClient,
) {
  const hash = await walleClient.deployContract({
    abi,
    account: walleClient.account as Account,
    bytecode,
    chain: walleClient.chain,
    args: [],
  });
  const receipt = await publicClient.waitForTransactionReceipt({ hash });
  return receipt.contractAddress as `0x${string}`;
}
