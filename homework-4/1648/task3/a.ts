import { ethers } from 'ethers';

// 假设你有一个私钥
const privateKey = '0x5fb92d6e98884f76de468fa3f6278f8807c48bebc13595d45af5bdc4da702133';

const wallet = new ethers.Wallet(privateKey);

// 生成公钥
// 使用 wallet.privateKey 来获取公钥
const pubKey = ethers.utils.computePublicKey(wallet.privateKey);

console.log('Public Key:', pubKey);
