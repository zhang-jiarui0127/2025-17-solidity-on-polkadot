require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    lineaSepolia: {
      url: process.env.LINEA_SEPOLIA_RPC_URL,
      accounts: [process.env.LOCAL_PRIV_KEY],
      chainId: 59141,
    },
  },
  etherscan: {
    apiKey: {
      lineaSepolia: process.env.LINEA_API_KEY,
    },
    customChains: [
      {
        network: "lineaSepolia",
        chainId: 59141,
        urls: {
          apiURL: "https://api-sepolia.lineascan.build/api",
          browserURL: "https://sepolia.lineascan.build",
        },
      },
    ],
  },
};
