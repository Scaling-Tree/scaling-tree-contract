import hre, { ethers } from "hardhat";
import addresses from "../../utils/addresses";

async function main() {
  const TreeAuditorRegistry = await ethers.getContractFactory("TreeAuditorRegistry");

  const treeAuditorRegistry = await TreeAuditorRegistry.deploy();

  console.log("TreeAuditorRegistry contract has been deployed to ", treeAuditorRegistry.address);

  await addresses.saveAddresses(hre.network.name, { TreeAuditorRegistry: treeAuditorRegistry.address });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
