import { ethers, Wallet } from 'ethers';
// storage编译生成ABI和BYTECODE
import { ABI, BYTECODE } from './storageAbi_bytecode';

async function main() {
  // 初始化provider
  const url = 'http://127.0.0.1:8545';
  const provider = new ethers.JsonRpcProvider(url);
  // anvil生成地址和私钥
  const privateKey =
    '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';
  // 创建钱包
  const wallet = new Wallet(privateKey, provider);
  const walletAddress = await wallet.getAddress();
  //检查钱包地址是否存在
  console.log('My wallet Address is: ', walletAddress);

  // 创建合约工厂&获取合约地址
  const contractFactory = new ethers.ContractFactory(ABI, BYTECODE, wallet);
  const contract = await contractFactory.deploy();
  const contractAddress = contract.target.toString();
  // 检查合约地址
  console.log('Contract deployed to:', contractAddress);

  // 创建合约实例  重复使用了相同的nonce
  const contractFun = new ethers.Contract(contractAddress, ABI, wallet);

  // 确保每次发送交易时 nonce 是递增
  const currentNonce = await wallet.getNonce();

  // 调用合约的方法
  async function setNumber(contract: ethers.Contract, newNum: number) {
    const tx = await contract.setNumber(newNum, {
      nonce: currentNonce,
      gasLimit: 200000,
    });
    await tx.wait();
    console.log(`Number set to: ${newNum}`);
  }

  // 侦听事件
  function listenForNumChanged(contract: ethers.Contract) {
    contract.on('oldNum', (oldNumber: number) => {
      console.log(`oldNum is: ${oldNumber}`);
    });
    contract.on('NumChanged', (newNumber: number) => {
      console.log(`Number changed to: ${newNumber}`);
    });
  }

  listenForNumChanged(contractFun);
  await setNumber(contractFun, 666);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
