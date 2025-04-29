import {
  Address,
  createPublicClient,
  createWalletClient,
  defineChain,
  formatEther,
  http,
  parseEther,
} from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { TokenA } from './contracts/TokenA';
import { TokenB } from './contracts/TokenB';
import { MinimalDEX } from './contracts/minimalDEX';
import 'dotenv/config';

const ahChain = defineChain({
  id: 420420421,
  name: 'ah',
  nativeCurrency: {
    name: 'Ether',
    symbol: 'ETH',
    decimals: 18,
  },
  rpcUrls: {
    default: {
      http: ['https://westend-asset-hub-eth-rpc.polkadot.io'],
    },
  },
  testnet: true,
});

const publicClient = createPublicClient({
  chain: ahChain,
  transport: http(),
});

const walletClient = createWalletClient({
  // @ts-ignore
  account: privateKeyToAccount(process.env.AH_PRIV_KEY! as Address),
  chain: ahChain,
  transport: http(),
});

const balanceOfToken = async (contract: any, token: string) => {
  const balanceOfToken = await publicClient.readContract({
    address: contract.address,
    abi: contract.abi,
    functionName: 'balanceOf',
    args: [walletClient.account.address],
  });
  console.log(`Balance of ${token}: ${formatEther(balanceOfToken as bigint)}`);
};

const approveToken = async (
  contract: any,
  address: Address,
  amount: bigint,
  token: string,
) => {
  console.log(`Approving ${formatEther(amount)} ${token} for MinimalDEX...`);
  const approveTokenTx = await walletClient.writeContract({
    address: contract.address,
    abi: contract.abi,
    functionName: 'approve',
    args: [address, amount],
  });
  await publicClient.waitForTransactionReceipt({ hash: approveTokenTx });
  console.log('Approved');
};

const allowanceOfToken = async (
  contract: any,
  address: Address,
  token: string,
) => {
  const allowanceOfToken = await publicClient.readContract({
    address: contract.address,
    abi: contract.abi,
    functionName: 'allowance',
    args: [walletClient.account.address, address],
  });
  console.log(
    `Allowance of ${token} for MinimalDEX: ${formatEther(
      allowanceOfToken as bigint,
    )}`,
  );
};

const reserveOfToken = async (contract: any, reserveToken: string) => {
  const reserve = await publicClient.readContract({
    address: contract.address,
    abi: contract.abi,
    functionName: reserveToken,
    args: [],
  });
  console.log(`${reserveToken}: `, formatEther(reserve as bigint));
};

const main = async () => {
  await balanceOfToken(TokenA, 'TokenA');
  await balanceOfToken(TokenB, 'TokenB');

  console.log('----------');

  await approveToken(TokenA, MinimalDEX.address, parseEther('100'), 'TokenA');
  await allowanceOfToken(TokenA, MinimalDEX.address, 'TokenA');

  console.log('----------');

  await approveToken(TokenB, MinimalDEX.address, parseEther('100'), 'TokenB');
  await allowanceOfToken(TokenB, MinimalDEX.address, 'TokenB');

  console.log('----------');

  console.log('Adding liquidity...');
  const addLiquidityTx = await walletClient.writeContract({
    address: MinimalDEX.address,
    abi: MinimalDEX.abi,
    functionName: 'addLiquidity',
    args: [parseEther('100'), parseEther('100')],
  });
  await publicClient.waitForTransactionReceipt({ hash: addLiquidityTx });

  console.log('----------');

  await reserveOfToken(MinimalDEX, 'reserveA');
  await reserveOfToken(MinimalDEX, 'reserveB');

  console.log('----------');

  await balanceOfToken(TokenA, 'TokenA');
  await balanceOfToken(TokenB, 'TokenB');

  console.log('----------');

  console.log('Preparing for Swap...');

  await approveToken(TokenA, MinimalDEX.address, parseEther('10'), 'TokenA');
  await allowanceOfToken(TokenA, MinimalDEX.address, 'TokenA');

  console.log('----------');

  console.log('Swapping 10 TokenA for TokenB...');
  const swapTokenAToBTx = await walletClient.writeContract({
    address: MinimalDEX.address,
    abi: MinimalDEX.abi,
    functionName: 'swap',
    args: [TokenA.address, parseEther('10')],
  });
  await publicClient.waitForTransactionReceipt({ hash: swapTokenAToBTx });

  console.log('----------');

  await reserveOfToken(MinimalDEX, 'reserveA');
  await reserveOfToken(MinimalDEX, 'reserveB');

  console.log('----------');

  await balanceOfToken(TokenA, 'TokenA');
  await balanceOfToken(TokenB, 'TokenB');

  console.log('---------');

  console.log('Removing 30 liquidity...');
  const removeLiquidityTx = await walletClient.writeContract({
    address: MinimalDEX.address,
    abi: MinimalDEX.abi,
    functionName: 'removeLiquidity',
    args: [parseEther('30')],
  });
  await publicClient.waitForTransactionReceipt({ hash: removeLiquidityTx });

  console.log('----------');

  await reserveOfToken(MinimalDEX, 'reserveA');
  await reserveOfToken(MinimalDEX, 'reserveB');
};

main();
