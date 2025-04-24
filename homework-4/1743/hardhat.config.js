require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ignition");
require("dotenv").config();

require("hardhat-resolc");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    hardhat: {
      polkavm: true,
    },
    polkavm: {
      polkavm: true,
      url: "http://127.0.0.1:8545",
      accounts: [process.env.POLKAVM_PRIV_KEY],
    },
    ah: {
      polkavm: true,
      url: "https://westend-asset-hub-eth-rpc.polkadot.io",
      accounts: [process.env.LOCAL_PRIV_KEY],
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
