import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-etherscan";
import "@openzeppelin/hardhat-upgrades";
import { config as dotenvConfig } from "dotenv";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import { HardhatUserConfig } from "hardhat/config";
import { NetworkUserConfig } from "hardhat/types";
import "solidity-coverage";
import { resolve } from "path";

//https://hardhat.org/guides/create-task.html
import "./scripts/accounts";

const DEFAULT_GAS_MULTIPLIER: number = 1;

dotenvConfig({ path: resolve(__dirname, "./.env") });

// Ensure that we have all the environment variables we need.
// const mnemonic: string | undefined = process.env.MNEMONIC;
// if (!mnemonic) {
//   throw new Error("Please set your MNEMONIC in a .env file");
// }

const infuraApiKey: string | undefined = process.env.INFURA_API_KEY;
if (!infuraApiKey) {
  throw new Error("Please set your INFURA_API_KEY in a .env file");
}

const chainIds = {
  //"arbitrum-mainnet": 42161,
  // avalanche: 43114,
  // bsc: 56,
  hardhat: 31337,
  mainnet: 1,
  // "optimism-mainnet": 10,
  // "polygon-mainnet": 137,
  // "polygon-mumbai": 80001,
  rinkeby: 4,
};

function getChainConfig(chain: keyof typeof chainIds): NetworkUserConfig {
  let jsonRpcUrl: string;
  switch (chain) {
    // case "avalanche":
    //   jsonRpcUrl = "https://api.avax.network/ext/bc/C/rpc";
    //   break;
    // case "bsc":
    //   jsonRpcUrl = "https://bsc-dataseed1.binance.org";
    //   break;
    default:
      jsonRpcUrl = "https://" + chain + ".infura.io/v3/" + infuraApiKey;
  }
  return {
    // accounts: {
    //   count: 10,
    //   //mnemonic,
    //   path: "m/44'/60'/0'/0",
    // },
    chainId: chainIds[chain],
    url: jsonRpcUrl,
  };
}

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.15",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  defaultNetwork: "hardhat",
  etherscan: {
    apiKey: {
      arbitrumOne: process.env.ARBISCAN_API_KEY || "",
      avalanche: process.env.SNOWTRACE_API_KEY || "",
      bsc: process.env.BSCSCAN_API_KEY || "",
      mainnet: process.env.ETHERSCAN_API_KEY || "",
      optimisticEthereum: process.env.OPTIMISM_API_KEY || "",
      polygon: process.env.POLYGONSCAN_API_KEY || "",
      polygonMumbai: process.env.POLYGONSCAN_API_KEY || "",
      rinkeby: process.env.ETHERSCAN_API_KEY || "",
    },
  },

  gasReporter: {
    enabled: true, //process.env.REPORT_GAS ? true : false,
    gasPriceApi: process.env.GASPRICE_API_ENDPOINT,
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
    showTimeSpent: true,
    showMethodSig: true,
    token: "ETH",
    currency: "USD",
    excludeContracts: [],
    src: "./contracts",
  },
  networks: {
    hardhat: {
      accounts: {
        //mnemonic,
      },
      chainId: chainIds.hardhat,
    },
    truffle: {
      url: 'http://localhost:24012/rpc',
      timeout: 60000,
      gasMultiplier: DEFAULT_GAS_MULTIPLIER,
    },
    // arbitrum: getChainConfig("arbitrum-mainnet"),
    // avalanche: getChainConfig("avalanche"),
    // bsc: getChainConfig("bsc"),
    mainnet: getChainConfig("mainnet"),
    // optimism: getChainConfig("optimism-mainnet"),
    // "polygon-mainnet": getChainConfig("polygon-mainnet"),
    // "polygon-mumbai": getChainConfig("polygon-mumbai"),
    rinkeby: getChainConfig("rinkeby"),
  },
  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./test",
  },
};

export default config;
