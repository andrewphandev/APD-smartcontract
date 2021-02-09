require('dotenv').config();
const HDWalletProvider = require('truffle-hdwallet-provider');
const mnemonic = process.env.MNEMONIC || '';

const BSCSCANAPIKEY = process.env.BSCSCANAPIKEY || '';
const POLYGONSCANAPIKEY = process.env.POLYGONSCANAPIKEY || '';
module.exports = {
  plugins: ['truffle-plugin-verify'],
  api_keys: {
    bscscan: BSCSCANAPIKEY,
    polygonscan: POLYGONSCANAPIKEY,
  },
  networks: {
    development: {
      host: '127.0.0.1', // Localhost (default: none)
      port: 8545, // Standard BSC port (default: none)
      network_id: '*', // Any network (default: none)
    },
    testnet: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `https://data-seed-prebsc-2-s1.binance.org:8545`
        ),
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
    bsc: {
      provider: () =>
        new HDWalletProvider(mnemonic, `https://bsc-dataseed1.binance.org`),
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
    matic: {
      provider: () =>
        new HDWalletProvider(mnemonic, `https://rpc-mumbai.maticvigil.com`),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
    },

    maticmainnet: {
      provider: () => new HDWalletProvider(mnemonic, `https://polygon-rpc.com`),
      network_id: 137,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
    coinextestnet: {
      provider: () =>
        new HDWalletProvider(mnemonic, 'https://testnet-rpc.coinex.net'),
      network_id: 53,
      gasPrice: 500000000000,
    },
    coinexmainnet: {
      provider: () => new HDWalletProvider(mnemonic, 'https://rpc.coinex.net'),
      network_id: 52,
      gasPrice: 500000000000,
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },
  compilers: {
    solc: {
      version: '>=0.8.0',
      settings: { optimizer: { enabled: true, runs: 200 } },
    },
  },
};
