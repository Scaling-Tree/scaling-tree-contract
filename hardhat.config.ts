import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import accountUtils from './utils/accounts';

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.18",
      }
    ]
  },
  networks: {
    gnosis: {
      url: `https://rpc.gnosischain.com/`,
      accounts: accountUtils.getAccounts(),
    },
    gnosis_test: {
      url: `https://rpc.chiadochain.net`,
      accounts: accountUtils.getAccounts(),
    },
  },
};

export default config;
