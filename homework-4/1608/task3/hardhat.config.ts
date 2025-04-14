import "@nomicfoundation/hardhat-toolbox"
import "@nomicfoundation/hardhat-ignition"

import "hardhat-resolc"
import { config } from "dotenv"
import "./tasks/compile-revive"
config()

module.exports = {
  solidity: "0.8.19",
  networks: {
    hardhat: {
      polkavm: true,
      nodeConfig: {
        nodeBinaryPath: "bin/substrate-node",
        rpcPort: 8000,
        dev: true,
      },
      adapterConfig: {
        adapterBinaryPath: "bin/eth-rpc",
        dev: true,
      },
    },
    polkavm: {
      polkavm: true,
      url: "http://127.0.0.1:8545",
      accounts: ["0x88dc3417d5058ec4b4503e0c12ea1a0a89be200fe98922423d4334014fa6b0ee"],
    },
    // polkavm: { url: "http://127.0.0.1:8545" },
    // ah: {
    //   url: "https://westend-asset-hub-eth-rpc.polkadot.io",
    //   accounts: [process.env.AH_PRIV_KEY],
    // },
  },
  // using remix compiler
  // resolc: {
  //   version: "1.5.2",
  //   compilerSource: "remix",
  //   settings: {
  //     optimizer: {
  //       enabled: false,
  //       runs: 600,
  //     },
  //     evmVersion: "istanbul",
  //   },
  // },

  // using binary compiler
  resolc: {
    compilerSource: "binary",
    settings: {
      optimizer: {
        enabled: true,
        runs: 400,
      },
      evmVersion: "istanbul",
      compilerPath: "bin/resolc-universal-apple-darwin",
      standardJson: true,
    },
  },
};