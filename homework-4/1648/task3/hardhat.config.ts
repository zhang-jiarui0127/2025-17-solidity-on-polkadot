import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-ignition"
import "@nomicfoundation/hardhat-toolbox";
import { config as configenv } from "dotenv"
import "hardhat-resolc"

import "./tasks/compile-revive"
import "./tasks/deploy-revive"

configenv();

const config: HardhatUserConfig = {
    solidity: "0.8.28",
    networks: {
      hardhat: {
        polkavm: true,
        // forking: {
        //   url: 'wss://westend-asset-hub-rpc.polkadot.io',
        // },
        // accounts: [{
        //   privateKey: '0x5fb92d6e98884f76de468fa3f6278f8807c48bebc13595d45af5bdc4da702133',
        //   balance: '10000000000'
        // }],
        nodeConfig: {
          nodeBinaryPath: "/Users/sxf/workspace/web3/polkadot-sdk/target/release/substrate-node",
          rpcPort: 8080,
          dev: true,

        },
        adapterConfig: {
          adapterBinaryPath: "/Users/sxf/workspace/web3/polkadot-sdk/target/release/eth-rpc",
          dev: true,
        },
      },
      polkavm: {
        polkavm: true,
        gasLimit:36451736500281453,
        url: "http://127.0.0.1:8545",
        accounts: [process.env.LOCAL_PRIV_KEY],
      },
      // polkavm: { url: "http://127.0.0.1:8545" },
      ah: {
        url: "https://westend-asset-hub-eth-rpc.polkadot.io",
        accounts: [process.env.AH_PRIV_KEY],
      },
    },
    // using binary compiler
    resolc: {
      compilerSource: "binary",
      settings: {
        optimizer: {
          enabled: true,
          runs: 400,
        },
        evmVersion: "istanbul",
        compilerPath: "/Users/sxf/.cargo/bin/resolc",
        standardJson: true,
      },
    },
};

export default config;
