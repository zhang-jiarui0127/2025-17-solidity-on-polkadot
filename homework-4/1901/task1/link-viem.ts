import { createPublicClient, createWalletClient, http } from "viem";
import { sepolia } from "viem/chains";
import { privateKeyToAccount } from "viem/accounts";
import { linkAbi } from "./abi";
import { LINK_ADDRESSES, ALCHEMY_SEPOLIA_RPC, PRIVATE_KEY } from "./config";

const publicClient = createPublicClient({
  chain: sepolia,
  transport: http(ALCHEMY_SEPOLIA_RPC),
});

const account = privateKeyToAccount(`0x${PRIVATE_KEY}`);
const walletClient = createWalletClient({
  account,
  chain: sepolia,
  transport: http(ALCHEMY_SEPOLIA_RPC),
});

const link_address = LINK_ADDRESSES["sepolia"] as `0x${string}`;

async function main() {

  const name = await publicClient.readContract({
    address: link_address,
    abi: linkAbi,
    functionName: "name",
  });

  const symbol = await publicClient.readContract({
    address: link_address,
    abi: linkAbi,
    functionName: "symbol",
  });

  const decimals = await publicClient.readContract({
    address: link_address,
    abi: linkAbi,
    functionName: "decimals",
  });

  const balance = await publicClient.readContract({
    address: link_address,
    abi: linkAbi,
    functionName: "balanceOf",
    args: ["0x000000000000000000000000000000000000dEaD"],
  });

  console.log(`代币名称: ${name}`);
  console.log(`代币符号: ${symbol}`);
  console.log(`精度: ${decimals}`);
  console.log(
    `0x...dEaD 地址余额: ${Number(balance) / 10 ** Number(decimals)} ${symbol}`
  );

  // 获取当前账号地址
  const senderAddress = account.address;

  // 转账前余额
  const balanceBefore = await publicClient.readContract({
    address: link_address,
    abi: linkAbi,
    functionName: "balanceOf",
    args: [senderAddress],
  });

  console.log(`转账前余额: ${Number(balanceBefore) / 10 ** Number(decimals)} ${symbol}`);

  // 发送 transfer
  const amount = 0.1; // 单位: LINK
  const amountInWei = BigInt(amount * 10 ** Number(decimals));
  const hash = await walletClient.writeContract({
    address: link_address,
    abi: linkAbi,
    functionName: "transfer",
    args: ["0x000000000000000000000000000000000000dEaD", amountInWei], // 1 LINK (18 decimals)
  });

  console.log(`从 ${senderAddress} 转账到 0x000000000000000000000000000000000000dEaD，数量为 ${amount} ${symbol}`);
  console.log("Transfer 成功，交易哈希:", hash);

  // 转账后余额
  const balanceAfter = await publicClient.readContract({
    address: link_address,
    abi: linkAbi,
    functionName: "balanceOf",
    args: [senderAddress],
  });

  console.log(`转账后余额: ${Number(balanceAfter) / 10 ** Number(decimals)} ${symbol}`);

}

main().catch(console.error);
