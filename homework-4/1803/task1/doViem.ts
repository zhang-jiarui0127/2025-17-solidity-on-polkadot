import { deployContractByViem } from './contract'
import { ABI, BYTECODE } from './storage'
import { getViemWalletClient, getViemPublicClient } from './wallet'

/**
 * viem contract address: 0x657b92725caedc273a2e4cf89318d12894af2854
  viem contract beforeRetrieve: 0n
  Tx hash: 0xffe26b2a2c425468e3a42dcc503d2c277a861355c5953379e149767d9252a5df
  Transaction succeeded
  viem contract afterRetrieve: 200n
 */
;(async () => {
  const viemWalletClient = await getViemWalletClient()
  const viemPublicClient = await getViemPublicClient()
  const contract = await deployContractByViem(ABI, BYTECODE, viemPublicClient, viemWalletClient)
  console.log('viem contract address:', contract)

  const beforeRetrieve = await viemPublicClient.readContract({
    address: contract,
    abi: ABI,
    functionName: 'retrieve',
    args: [],
  })
  console.log('viem contract beforeRetrieve:', beforeRetrieve)
  
  const tx = await viemWalletClient.writeContract({
    address: contract,
    abi: ABI,
    functionName: 'store',
    args: [200 + Number(beforeRetrieve)],
  })
  console.log('Tx hash:', tx)

  const receipt = await viemPublicClient.waitForTransactionReceipt({
    hash: tx,
    confirmations: 1,
  })

  if (receipt.status !== 'success') {
    throw new Error('Transaction failed')
  }
  console.log('Transaction succeeded')

  const afterRetrieve = await viemPublicClient.readContract({
    address: contract,
    abi: ABI,
    functionName: 'retrieve',
    args: [],
  })
  console.log('viem contract afterRetrieve:', afterRetrieve)
})()
