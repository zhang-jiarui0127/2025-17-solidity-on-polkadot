import { ethersMethod } from "./ethersMethod.js";
import {viemMethod} from "./viemMethod.js"

async function main() {
    try {
      await ethersMethod();
      await viemMethod();
    } catch (error) {
      console.error("💥 执行出错:", error);
      process.exit(1);
    }
  }
  
  main();