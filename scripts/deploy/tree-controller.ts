import hre, { ethers } from "hardhat";
import addresses from "../../utils/addresses";

async function main() {
    const addressList = await addresses.getAddressList(hre.network.name);
    const TreeController = await ethers.getContractFactory("TreeController");

    const treeNFTAddress = addressList['TreeNFT'];
    const treeAuditorRegistry = addressList['TreeAuditorRegistry'];

    const treeController = await TreeController.deploy(treeNFTAddress, treeAuditorRegistry);

    console.log("Tree controller contract has been deployed to ", treeController.address);

    await addresses.saveAddresses(hre.network.name, { TreeController: treeController.address });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
