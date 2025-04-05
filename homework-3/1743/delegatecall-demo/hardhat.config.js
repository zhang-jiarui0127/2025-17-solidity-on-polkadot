require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ignition");
require("hardhat-revive-node");
require("./tasks/compile-revive");
require("./tasks/deploy-revive");
require("dotenv").config();

require("hardhat-resolc");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    hardhat: {
      polkavm: true, // Change to true if you want to use the Polkadot VM
    },
    ah: {
      polkavm: true,
      url: "https://westend-asset-hub-eth-rpc.polkadot.io",
      accounts: [process.env.LOCAL_PRIV_KEY],
    },

    sepolia: {
      url: "https://eth-sepolia.public.blastapi.io",
      accounts: [process.env.LOCAL_PRIV_KEY],
    },

    moonbase: {
      url: "https://rpc.api.moonbase.moonbeam.network",
      accounts: [process.env.LOCAL_PRIV_KEY],
    },
  },
  resolc: {
    version: "1.5.2",
    compilerSource: "remix",
    settings: {
      optimizer: {
        enabled: false,
        runs: 600,
      },
      evmVersion: "istanbul",
    },
  },
};
