import hre, { ethers } from "hardhat";
import addresses from "../utils/addresses";

async function main() {
  const Tree = await ethers.getContractFactory("Tree");

  const tree = await Tree.deploy();

  console.log("Tree contract has been deployed to ", tree.address);

  await addresses.saveAddresses(hre.network.name, { Tree: tree.address });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
