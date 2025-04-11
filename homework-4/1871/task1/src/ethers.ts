import { Contract, ContractFactory, ethers } from 'ethers';
import {
  ACCOUNT1_PRIVATE_KEY,
  ACCOUNT2_ADDRESS,
  LOCAL_RPC_URL,
} from './constants';
import { ABI, BYTECODE } from './contract-data';

const provider = new ethers.JsonRpcProvider(LOCAL_RPC_URL);
const wallet = new ethers.Wallet(ACCOUNT1_PRIVATE_KEY, provider);

const watchBlockNumber = async () => {
  const currentBlockNumber = await provider.getBlockNumber();
  provider.on('block', (blockNumber) => {
    console.log(`The current block number is ${blockNumber}`);
    if (blockNumber >= currentBlockNumber + 2) {
      provider.removeAllListeners('block');
    }
  });
};

const deployContract = async () => {
  const contractFactory = await new ContractFactory(ABI, BYTECODE, wallet);
  const contract = await contractFactory.deploy();
  await contract.waitForDeployment();
  const contractAddress = await contract.getAddress();

  return contractAddress;
};

const sendTransition = async () => {
  const tx = await wallet.sendTransaction({
    to: ACCOUNT2_ADDRESS,
    value: ethers.parseEther('100'),
  });
  await tx.wait();

  const balanceOfAccount2 = await provider.getBalance(ACCOUNT2_ADDRESS);
  console.log(`The balance of account 2 is ${balanceOfAccount2}`);
};

const readContract = async (address: string) => {
  const contract = new Contract(address, ABI, provider);
  const favoriteNumber = await contract.favoriteNumber();

  return favoriteNumber;
};

const writeContract = async (address: string) => {
  const previousFavoriteNumber = await readContract(address);
  console.log(`The previous favorite number is ${previousFavoriteNumber}`);

  const contract = new Contract(address, ABI, wallet);
  const tx = await contract.store(previousFavoriteNumber + 1n);
  await tx.wait();

  const currentFavoriteNumber = await readContract(address);
  console.log(`The current favorite number is ${currentFavoriteNumber}`);
};

const main = async () => {
  watchBlockNumber();
  await sendTransition();

  const contractAddress = await deployContract();
  if (!contractAddress) {
    throw new Error('Contract deployment failed');
  }

  await writeContract(contractAddress);
};

main();
