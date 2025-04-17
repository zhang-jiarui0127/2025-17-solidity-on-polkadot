import { createClient, createPublicClient, createWalletClient, defineChain, getContract, http } from "viem"
import {privateKeyToAccount} from "viem/accounts"
import { ABI, BYTECODE } from "./Storage"

export const localChain = (url:string) => defineChain({
    id:31337,
    name:"Testnet",
    network:"Testnet",
    nativeCurrency: {
        name: "King",
        symbol: "KK",    
        decimals: 18    
    },    
    rpcUrls: {
        default:{
            http:[url]
        },

    },
    testnet: true,
})

async function main() {
    const url = "http://127.0.0.1:8545"
    const publicClient = createPublicClient({chain:localChain(url),transport:http()})
    const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    const wallet = privateKeyToAccount(privateKey)
    const walletAddress = wallet.address
    const walletClient = createWalletClient({account:wallet,chain:localChain(url),transport:http()})
    const formattedBytecode = `0x${BYTECODE}` as `0x${string}`; // 强制类型 `0x`


    // 部署合约
    const tx = await walletClient.deployContract({
       abi:ABI,
       bytecode:formattedBytecode,
       args:[]  
    })
    const receipt  = await publicClient.waitForTransactionReceipt({hash:tx})
    const contractAddress =receipt.contractAddress
    console.log(`deploy is ${receipt.status}, contractAddress is ${contractAddress}`)
    //读取合约
    if(typeof contractAddress !== 'string' || !contractAddress.startsWith('0x')){
        throw new Error(`Invalid contract address:${contractAddress}`)
    }
    let number = await publicClient.readContract({
        address:contractAddress,abi:ABI,functionName:"retrieve"
    })
    console.log(`初始 number=:${number}`);
    //写入合约
    const txHash = await walletClient.writeContract({
        address: contractAddress, 
        abi: ABI,
        functionName: 'store',
        args: [BigInt(13)]
    });
    const writeReceipt = await publicClient.waitForTransactionReceipt({hash:tx})
    console.log("交易状态:", writeReceipt.status === "success" ? "成功" : "失败");
    //更新后
    number = await publicClient.readContract({
        address:contractAddress,abi:ABI,functionName:"retrieve"
    })
    console.log(`更新后 number=:${number}`);

    //监控block
    let unwatch: (() => void) | null = null;
    unwatch = publicClient.watchBlockNumber({
        onBlockNumber:(blockNumber=> {
            console.log(`blockNumber is ${blockNumber}`)
            if(blockNumber > 3){
                if (unwatch) {
                    unwatch(); // 停止监听
                    unwatch = null;
                  }
            }
        })
    })

}

main()