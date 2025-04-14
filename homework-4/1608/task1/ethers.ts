// ethers-example.ts
import { ethers ,Wallet,Contract} from 'ethers';
import fs from 'fs';
import path from 'path';

async function main() {
    // 1. 设置提供商和钱包
    const provider = new ethers.JsonRpcProvider('http://127.0.0.1:8545/');//npx hardhat node
    const privateKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';

    const wallet = new Wallet(privateKey, provider);
    
    // 2. 读取合约ABI和字节码
    const artifactPath = path.join('./artifacts/contracts/Storage.sol/', 'Storage.json');
    const contractArtifact = JSON.parse(fs.readFileSync(artifactPath, 'utf-8'));
    
    // 3. 部署合约
    const StorageFactory = new ethers.ContractFactory( contractArtifact.abi, contractArtifact.bytecode, wallet);
    console.log('Deploying contract...');
    const storageContract = await StorageFactory.deploy();
    await storageContract.waitForDeployment();
    const contractAddress = await storageContract.getAddress();
    console.log('Contract deployed to:', contractAddress);
    
    // 4. 调用合约方法
    const contract = new Contract(contractAddress, contractArtifact.abi, wallet);
    console.log('Storing value 42...');
    const tx = await contract.store(42);
    await tx.wait();
    console.log('Value stored');
    
    // 读取值
    const value = await contract.retrieve();
    console.log('Retrieved value:', value.toString());
    
    // 5. 监听事件
    contract.on('ValueChanged', (newValue: bigint, event: ethers.EventLog) => {
        console.log('Event ValueChanged:', newValue.toString());
        contract.off('ValueChanged');
        console.log('Listener removed');
    });
    
    // 再次存储以触发事件
    console.log('Storing value 100...');
    await (await contract.store(100)).wait();
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});