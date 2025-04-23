import { Contract } from 'ethers';
import { deployContractByEthers } from './contract'
import { ABI, BYTECODE } from './storage'
import { getEtherClient, getEtherWallet } from './wallet'

/**
 * Wallet Address: 0x94FeFDbF9C0A57C7e9B35D491fa3F6171ea05346
  transactions count: 59
  ethers contract address: 0x95D8e5623d4069b69794293B7fCf05cd5901840F
  ethers contract beforeRetrieve: 0
  Tx hash: 0xa904501a9844533b4f260e534b0b213eba709479a1cc2a653c55b331e4d0b89d
  ethers contract afterRetrieve: 200
 */
;(async () => {
  const ethersProvider = getEtherClient();
  const ehtersWallet = getEtherWallet(ethersProvider);
  const txsCount = await ethersProvider.getTransactionCount(ehtersWallet.address)
  console.log('transactions count:', txsCount)
  const ethersContractAddr = await deployContractByEthers(
    ABI,
    BYTECODE,
    ehtersWallet
  )
  console.log('ethers contract address:', ethersContractAddr)
  // const ethersContractAddr = '0x512aE706DA3e17E29F97bE6668bdd8f90657D7E0'
  const ethersContract = await new Contract(ethersContractAddr, ABI, ehtersWallet)

  const beforeRetrieve = await ethersContract.retrieve()
  console.log('ethers contract beforeRetrieve:', beforeRetrieve.toString())
  const tx = await ethersContract.store(200 + Number(beforeRetrieve))
  console.log('Tx hash:', tx.hash)
  await tx.wait()
  const afterRetrieve = await ethersContract.retrieve()
  console.log('ethers contract afterRetrieve:', afterRetrieve.toString())
})()
