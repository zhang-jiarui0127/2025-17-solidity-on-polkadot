require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ignition");
require("hardhat-revive-node");
require("dotenv").config();

const USE_RESOLC = process.env.USE_RESOLC === "true";
if (USE_RESOLC) {
  require("hardhat-resolc");
}

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    hardhat: {
      polkavm: true,
      nodeConfig: {
        nodeBinaryPath:
          "/Users/changtong/Environment/polkadot-sdk/target/release/substrate-node",
        rpcPort: 8000,
        dev: true,
      },
      adapterConfig: {
        adapterBinaryPath:
          "/Users/changtong/Environment/polkadot-sdk/target/release/eth-rpc",
        dev: true,
      },
    },
    localNode: {
      polkavm: true,
      url: "http://127.0.0.1:8545",
      accounts: [process.env.LOCAL_PRIV_KEY],
    },
    westendAssetHub: {
      polkavm: true,
      url: "https://westend-asset-hub-eth-rpc.polkadot.io",
      accounts: [process.env.HA_PRIV_KEY],
    },
    lineaSepolia: {
      url: process.env.LINEA_SEPOLIA_RPC_URL,
      accounts: [process.env.EVM_PRIV_KEY],
      chainId: 59141,
    },
  },

  resolc: {
    compilerSource: "binary",
    settings: {
      optimizer: {
        enabled: true,
        runs: 400,
      },
      evmVersion: "istanbul",
      compilerPath: "~/.cargo/bin/resolc",
      standardJson: true,
    },
  },
};
