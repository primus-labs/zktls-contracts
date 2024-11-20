require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity:
  {
    compilers: [
      {
        version: "0.8.20",
      }
    ]
  },
  networks: {
    sepolia: {
        url: `https://sepolia.infura.io/v3/b6bf7d3508c941499b10025c0776eaf8`,
        accounts: [`${process.env.PRIVATE_KEY}`]
    },
    bsctestnet: {
      url: `https://data-seed-prebsc-1-s3.binance.org:8545`,
      accounts: [`${process.env.PRIVATE_KEY}`]
    },
    opbnbtestnet: {
      url: `https://opbnb-testnet-rpc.bnbchain.org`,
      accounts: [`${process.env.PRIVATE_KEY}`],
      gasPrice: 2000000000
    },
    arbitrumone: {
      url: `https://arb1.arbitrum.io/rpc`,
      accounts: [`${process.env.PRIVATE_KEY}`]
    },
    polygon: {
      url: `https://polygon-rpc.com/`,
      accounts: [`${process.env.PRIVATE_KEY}`]
    },
    mumbai: {
      url: `https://polygon-mumbai-bor.publicnode.com`,
      accounts: [`${process.env.PRIVATE_KEY}`]
    },
    bsc: {
      url: `https://bsc-dataseed.binance.org`,
      accounts: [`${process.env.PRIVATE_KEY}`]
    },
    opbnb: {
      url: `https://opbnb-rpc.publicnode.com`,
      accounts: [`${process.env.PRIVATE_KEY}`]
    },
    holesky: {
      url: `https://ethereum-holesky-rpc.publicnode.com`,
      accounts: [`${process.env.PRIVATE_KEY}`]
    },
    ethereum: {
      url: `https://rpc.ankr.com/eth`,
      accounts: [`${process.env.PRIVATE_KEY}`]
    }
  }
};
