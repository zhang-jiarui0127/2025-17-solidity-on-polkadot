import { getEtherClient, getEtherWallet, getViemClient, getViemWalletClient } from "./src/wallet"
import {
    deployContract,
    getContract,

} from "./src/contract";
import { ABI, BYTECODE } from "./src/erc20"
import { ethers } from "ethers";

async function subscribeToBalanceChanges(provider: ethers.Provider, address: string) {
    provider.on("block", async (blockNumber) => {
        console.log(`block is ${blockNumber}`)
        // const balance = await provider.getBalance(address);
        // const balanceEth = ethers.formatEther(balance);
        // provider.off("block")
        // console.log(`Block Number: ${blockNumber}, Address: ${address}, Balance: ${balanceEth} ETH`);
    });
}

async function main() {
    const provider = getEtherClient();

    // basic query
    const blockNumber = await provider.getBlockNumber()
    console.log(`${blockNumber}`)
    const wallet = getEtherWallet(provider)
    console.log(wallet)

    const balance = await provider.getBalance(wallet.address)
    console.log(`balance is ${balance}`)

    const balanceEth = ethers.formatEther(balance)
    console.log(`balance is ${balanceEth} eth`)

    const transfer = {
        to: "",
        value: "1000000000"
    }

    // send tx to mempool
    // const tx = await wallet.sendTransaction(transfer)
    // wait for tx included in block
    // await tx.wait()

    // Get the contract instance
    // const contractAddress = await deployContract(ABI, BYTECODE, wallet)
    // const contract = await getContract(contractAddress, provider, wallet)
    // console.log(contract)

    // Attach the wallet to the contract
    // const contractWithWallet = attachWalletToContract(contract, wallet)
    // console.log("Contract with wallet attached:", contractWithWallet)

    // Subscribe to balance changes
    subscribeToBalanceChanges(provider, wallet.address);
    // provider.off(unsub)

    // Now you can call contract methods that require signing
    // Example: const txResponse = await contractWithWallet.someMethod();
}

async function tryViem() {
    // two client
    const client = await getViemClient()
    const walletClient = await getViemWalletClient()
    const balance = await client.getBalance(walletClient.account)

    console.log(`balance is ${balance}`)

    const nonce = await client.getTransactionCount(walletClient.account)
    console.log(`nonce is ${nonce}`)

    // transfer
    const hash = await walletClient.sendTransaction({
        // account: walletClient.account,
        to: "0x90F79bf6EB2c4f870365E785982E1f101E93b906",
        value: BigInt(100)
    })
    console.log(`hash is ${hash}`)
    const receipt = await client.getTransactionReceipt({ hash: hash })
    console.log(`receipt is `, receipt)

    const afterNonce = await client.getTransactionCount(walletClient.account)
    console.log(`nonce is ${afterNonce}`)

    // get block
    const block = await client.getBlock()
    console.log(`block is `, block)

    // sub new block, unwatch need some time.
    const unwatch = client.watchBlocks({
        onBlock: block => {
            if (block.number > BigInt(16)) {
                unwatch()
            }
            console.log(block)
        }
    })


}
main()
