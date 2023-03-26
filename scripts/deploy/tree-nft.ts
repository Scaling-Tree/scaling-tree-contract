import hre, { ethers } from "hardhat";
import addresses from "../../utils/addresses";

async function main() {
  const TreeNFT = await ethers.getContractFactory("TreeNFT");

  const treeNFT = await TreeNFT.deploy();

  console.log("TreeNFT contract has been deployed to ", treeNFT.address);

  await addresses.saveAddresses(hre.network.name, { TreeNFT: treeNFT.address });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
