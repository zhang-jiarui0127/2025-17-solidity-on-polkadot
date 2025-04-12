import { Contract } from "ethers"
import { ethers, Wallet } from "ethers"

// Hardhat/Anvil 本地节点
const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545")
const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
const wallet = new Wallet(privateKey, provider)

const ABI = [
  {
    anonymous: false,
    inputs: [{ indexed: false, internalType: "uint256", name: "newNumber", type: "uint256" }],
    name: "NumberChanged",
    type: "event"
  },
  { inputs: [], name: "get", outputs: [{ internalType: "uint256", name: "", type: "uint256" }], stateMutability: "view", type: "function" },
  { inputs: [{ internalType: "uint256", name: "num", type: "uint256" }], name: "set", outputs: [], stateMutability: "nonpayable", type: "function" }
]
const BYTECODE = "0x608060405234801561001057600080fd5b50610187806100206000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c806360fe47b11461003b5780636d4ce63c14610057575b600080fd5b610055600480360381019061005091906100fa565b610075565b005b61005f6100b6565b60405161006c9190610136565b60405180910390f35b806000819055507f2fd81fd19d3c5c4b396dd13f451dafc8bcac1b3094c49c5fa90e68456323f0e3816040516100ab9190610136565b60405180910390a150565b60008054905090565b600080fd5b6000819050919050565b6100d7816100c4565b81146100e257600080fd5b50565b6000813590506100f4816100ce565b92915050565b6000602082840312156101105761010f6100bf565b5b600061011e848285016100e5565b91505092915050565b610130816100c4565b82525050565b600060208201905061014b6000830184610127565b9291505056fea2646970667358221220ca8f307be898689d1358af5e6be6c1828c92453e60d4948f63edc7001e32017d64736f6c63430008140033"

async function main() {
  const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet)
  const contract = await factory.deploy()
  await contract.waitForDeployment()

  // 👇 明確指定型別
  const deployed = contract as Contract

  const tx = await deployed.set(42)
  await tx.wait()

  const value = await deployed.get()
  console.log("Stored value:", value.toString())

  deployed.on("NumberChanged", (newNumber: bigint) => {
    console.log("Event: NumberChanged =", newNumber.toString())
  })

  await deployed.set(99)
}

main().catch(console.error)
