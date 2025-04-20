import { read } from "fs"
import {ABI, BYTECODE} from "./erc20"

import { readFileSync } from "node:fs";
import { privateKeyToAccount } from "viem/accounts";

import {
  createPublicClient,
  createWalletClient,
  defineChain,
  getContract,
  hexToBigInt,
  http,
} from "viem";


const localChain = (url: string) => defineChain({
      id: 31337,
      name: "Testnet",
      network: "Testnet",
      nativeCurrency: {
        name: "ETH",
        symbol: "ETH",
        decimals: 18,
      },
      rpcUrls: {
        default: {
          http: [url],
        },
      },
      testnet: true,
    });
  

async function main(){
    const url = "http://127.0.0.1:8545" // 本地node节点的url
    const publicClient = createPublicClient({
        chain: localChain(url),
        transport: http(),
      });
    const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    const wallet = privateKeyToAccount(privateKey);
    const walletAddress = wallet.address; 
    console.log(`result is: walletAddress ${walletAddress}`)

    const balance = await publicClient.getBalance({
        address: walletAddress,
      });
    console.log(`result is: balance ${balance}`)

    const walletClient = createWalletClient({
        account: wallet,
        chain: localChain(url),
        transport: http(),
      });

    const tx = await walletClient.sendTransaction({
        account: wallet,
        to: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
        value: hexToBigInt("0x1"),
      });
    console.log(`result is: tx ${tx}`)
    
    // 部署智能合约
    const txTwo = await walletClient.deployContract({
        abi: ABI,
        bytecode: BYTECODE,
        args: ["daijinwei", "okko", 18, 10000000000000000],
      });
    console.log(`result is: txTwo ${txTwo}`)

    const receipt = await publicClient.waitForTransactionReceipt({ hash: txTwo });

    const contractAddress = receipt.contractAddress;
    console.log(`result is: contractAddress ${contractAddress}`)
    if ( typeof contractAddress !== "string" || !contractAddress.startsWith("0x") ) {
        throw new Error("Contract address is not a string");
    }
    
    const totalSupply = await publicClient.readContract({
        address: contractAddress,
        abi: ABI,
        functionName: "totalSupply",
        args: [],
      });
    console.log(`result is: totalSupply ${totalSupply}`)
    
    const writeContract = getContract({
        address: contractAddress,
        abi: ABI,
        client: walletClient,
      });

    const txThree = await writeContract.write.transfer( ["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", hexToBigInt("0x11122465700000000000")]);
    console.log(`result is: txThree ${txThree}`)    
      
    const balanceOf = await publicClient.readContract({
        address: contractAddress,
        abi: ABI,
        functionName: "balanceOf",
        args: ["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"],
      });
    console.log(`result is: balanceOf ${balanceOf}`)


    
  //   console.log(
  //     "Retrieve after store:",
  //     await publicClient.readContract({
  //       address: contractAddress,
  //       abi: JSON.parse(ABI),
  //       functionName: "retrieve",
  //       args: [],
  //     })
  //   );

  publicClient.watchBlockNumber({
    onBlockNumber: async (blockNumber) => {
      console.log("Block Number:", blockNumber);
    },
  });
}

main()