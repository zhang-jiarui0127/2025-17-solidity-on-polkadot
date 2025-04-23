import { ethers } from "ethers";

async function listenBlocks() {
    // 1. 使用WebSocket Provider（
    const provider = new ethers.WebSocketProvider(
        "ws://127.0.0.1:8545"
    );

    console.log("开始监听区块...");


    // 正确的block监听器
    provider.on("block", (blockNumber) => {
        console.log(`当前区块: ${blockNumber}`);

        if (blockNumber > 55) {
            console.log("已达到目标区块，取消监听");
            provider.off("block"); // 取消监听
            provider.removeAllListeners(); // 移除所有监听器
        } else {
            console.log(`区块 ${blockNumber} 未达到55`);
        }
    });


}

listenBlocks().catch(console.error);
