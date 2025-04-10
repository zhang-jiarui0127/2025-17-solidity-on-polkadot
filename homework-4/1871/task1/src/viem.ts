import {
  Address,
  createPublicClient,
  createWalletClient,
  defineChain,
  getContract,
  http,
} from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import {
  ACCOUNT1_PRIVATE_KEY,
  ACCOUNT2_ADDRESS,
  LOCAL_RPC_URL,
} from './constants';
import { ABI, BYTECODE } from './contract-data';

const localChain = defineChain({
  id: 31337,
  name: 'Local Chain',
  nativeCurrency: {
    name: 'Ether',
    symbol: 'ETH',
    decimals: 18,
  },
  rpcUrls: {
    default: {
      http: [LOCAL_RPC_URL],
    },
  },
  testnet: true,
});
const publicClient = createPublicClient({
  chain: localChain,
  transport: http(),
});
const walletClient = createWalletClient({
  chain: localChain,
  transport: http(),
  account: privateKeyToAccount(ACCOUNT1_PRIVATE_KEY),
});

const watchBlockNumber = async () => {
  const currentBlockNumber = await publicClient.getBlockNumber();
  const unwatch = publicClient.watchBlockNumber({
    onBlockNumber: (blockNumber) => {
      console.log(`The current block number is ${blockNumber}`);
      if (currentBlockNumber + BigInt(2) >= blockNumber) {
        unwatch();
      }
    },
  });
};

const deployContract = async () => {
  const tx = await walletClient.deployContract({
    abi: ABI,
    bytecode: BYTECODE,
  });

  const { contractAddress } = await publicClient.waitForTransactionReceipt({
    hash: tx,
  });

  return contractAddress;
};

const readContract = async (address: Address) => {
  const previousFavoriteNumber = await publicClient.readContract({
    abi: ABI,
    address,
    functionName: 'favoriteNumber',
  });

  return previousFavoriteNumber;
};

const writeContract = async (address: Address) => {
  const previousFavoriteNumber = await readContract(address);
  console.log(`The previous favorite number is ${previousFavoriteNumber}`);

  const tx = await walletClient.writeContract({
    abi: ABI,
    address,
    functionName: 'store',
    args: [previousFavoriteNumber + BigInt(1)],
  });
  await publicClient.waitForTransactionReceipt({ hash: tx });

  const currentFavoriteNumber = await readContract(address);
  console.log(`The current favorite number is ${currentFavoriteNumber}`);
};

const useGetContractInstance = async (address: Address) => {
  const contract = getContract({
    abi: ABI,
    address,
    client: publicClient,
  });

  const favoriteNumber = await contract.read.favoriteNumber();
  console.log(`[getContract] The favorite number is ${favoriteNumber}`);
};

const sendTransition = async () => {
  const tx = await walletClient.sendTransaction({
    to: ACCOUNT2_ADDRESS,
    value: 1000n,
  });
  await publicClient.waitForTransactionReceipt({ hash: tx });

  const balanceOfAccount2 = await publicClient.getBalance({
    address: ACCOUNT2_ADDRESS,
  });
  console.log(`The balance of account 2 is ${balanceOfAccount2}`);
};

const main = async () => {
  watchBlockNumber();
  await sendTransition();

  const contractAddress = await deployContract();
  if (!contractAddress) {
    throw new Error('Contract deployment failed');
  }

  await writeContract(contractAddress);
  await useGetContractInstance(contractAddress);
};

main();
