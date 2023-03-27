import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import accountUtils from "./utils/accounts";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.18",
      },
    ],
  },
  networks: {
    optimism: {
      url: process.env.OPTIMISM_URL,
      accounts: accountUtils.getAccounts(),
    },
    zkevm: {
      url: "https://rpc.public.zkevm-test.net",
      accounts: accountUtils.getAccounts(),
    },
    gnosis: {
      url: `https://rpc.gnosis.gateway.fm`,
      accounts: accountUtils.getAccounts(),
    },
    gnosis_testnet: {
      url: `https://rpc.chiadochain.net`,
      accounts: accountUtils.getAccounts(),
    },
    taiko_testnet: {
      url: `https://rpc.a2.taiko.xyz`,
      accounts: accountUtils.getAccounts(),
    },
    polygon_zkEVM_testnet: {
      url: `https://rpc.public.zkevm-test.net`,
      accounts: accountUtils.getAccounts(),
    },
    mantle_testnet: {
      url: `https://rpc.testnet.mantle.xyz/`,
      accounts: accountUtils.getAccounts(),
    },
    scroll_testnet: {
      url: `https://alpha-rpc.scroll.io/l2`,
      accounts: accountUtils.getAccounts(),
    },
    optimism_mainnet: {
      url: `https://mainnet.optimism.io`,
      accounts: accountUtils.getAccounts(),
    },
    goerli: {
      url: process.env.GOERLI_URL,
      accounts: accountUtils.getAccounts(),
    },
  },
};

export default config;
