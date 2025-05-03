import { createPublicClient, http } from "viem";
import { sepolia } from "viem/chains";
import { linkAbi } from "./abi";
import { LINK_ADDRESSES } from "./config";
import { ALCHEMY_SEPOLIA_RPC } from "./config";

async function main() {
  const publicClient = createPublicClient({
    chain: sepolia,
    transport: http(ALCHEMY_SEPOLIA_RPC),
  });

  const link_address = LINK_ADDRESSES["sepolia"] as `0x${string}`;

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
}

main().catch(console.error);
