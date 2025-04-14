import * as dotenv from 'dotenv';
import { ethers } from 'ethers';

dotenv.config();

interface EnvConfig {
    localRpcUrl: string;
    privateKey: `0x${string}`;
    accountAddress2: `0x${string}`;
}

// 验证以太坊地址格式
const validateEthAddress = (address: string): address is `0x${string}` => {
    return ethers.isAddress(address);
};

// 验证私钥格式
const validatePrivateKey = (pk: string): pk is `0x${string}` => {
    return /^0x[a-fA-F0-9]{64}$/.test(pk);
};

const getConfig = (): EnvConfig => {
    // 带类型检查的默认值
    const defaultPrivateKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'; // Hardhat测试私钥
    const defaultAddress = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'; // Hardhat测试地址

    // 环境变量提取
    const privateKey = process.env.PRIVATE_KEY || defaultPrivateKey;
    const accountAddress2 = process.env.ACCOUNT_ADDRESS_2 || defaultAddress;

    // 运行时验证
    if (!validatePrivateKey(privateKey)) {
        throw new Error(`Invalid private key format: ${privateKey}`);
    }

    if (!validateEthAddress(accountAddress2)) {
        throw new Error(`Invalid Ethereum address: ${accountAddress2}`);
    }

    return {
        localRpcUrl: process.env.LOCAL_RPC_URL || 'http://127.0.0.1:8545',
        privateKey,
        accountAddress2,
    };
};

const config = getConfig();
export default config;
