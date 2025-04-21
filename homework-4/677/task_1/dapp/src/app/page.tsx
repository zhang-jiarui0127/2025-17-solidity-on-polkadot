import Image from "next/image";
import { Contract, ethers, Wallet } from "ethers"
import { ABI, BYTECODE } from "./erc20"

export default async function Home() {
  const url = "http://127.0.0.1:8545" // 本機的RPC
  const provider = new ethers.JsonRpcProvider(url) // 建立一個新的 Provider 實例
  const blockNumber = await provider.getBlockNumber() // 可以獲得當下的區塊數目
  const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" // 錢包的 private key

  console.log(`results is ${blockNumber}`)

  const wallet = new Wallet(privateKey, provider) // 建立一個新的 Wallet 實例
  const address = wallet.address // 獲取 Wallet 地址

  console.log(`address is ${address}`)

  const balance = await provider.getBalance(address) // 查看 Wallet 的餘額
  const nonce = await provider.getTransactionCount(address) // 獲取當中交易的 nonce
  console.log(`nonce is ${nonce}`)

  const transfer = {
    to: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", // 接收金額的地址
    value: "1000000000" // 要轉出的金額
  }

  //const tx = await wallet.sendTransaction(transfer) // 發起交易
  //await tx.wait() // 等待交易被打包到區塊
  //const hash = tx.hash // 獲取交易的 hash

  //console.log(`hash is ${hash}`)

  // 合約工廠
  const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet) // 會用到 ABI 和 BYTECODE 來建立一個 ContractFactory 實例
  const contract = await factory.deploy(1000000000000) // 進行合約部署
  await contract.waitForDeployment() // 
  const contractAddress = contract.target.toString() // 獲取完成部署後的合約地址
  console.log(`contractAddress is ${contractAddress}`)

  //const deployTx = await factory.getDeployTransaction(1000000000000);
  //console.log(deployTx.data); // 檢查 calldata 是否符合預期


  return (
    <div className="grid grid-rows-[20px_1fr_20px] items-center justify-items-center min-h-screen p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)]">
      <div>hello</div>
    </div>
  );
}
