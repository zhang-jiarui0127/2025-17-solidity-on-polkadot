import path from "path";
import { fileURLToPath } from "url";
import fs from "fs";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);


export function loadContractData() {
  try {
    const rawData = fs.readFileSync(
      path.join(__dirname, "./abi/Storage.json"),
      "utf8"
    );
    const { abi, bytecode } = JSON.parse(rawData);
    
    // 验证必要字段
    if (!abi || !bytecode?.object) {
      throw new Error("Invalid contract data structure");
    }
    
    return { abi, bytecode: bytecode.object };
  } catch (error) {
    console.error("❌ 加载合约数据失败:", error.message);
    process.exit(1);
  }
}