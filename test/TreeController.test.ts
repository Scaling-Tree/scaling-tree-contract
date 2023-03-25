import { expect } from "chai";
import hre, { ethers } from "hardhat";
import { TreeAuditorRegistry, TreeController, TreeNFT } from "../typechain-types";

describe("TreeController", function () {

    let externalNFT: TreeNFT;
    let treeNFT: TreeNFT;
    let auditorRegistry: TreeAuditorRegistry;
    let treeController: TreeController;

    this.beforeEach(async () => {
        const TreeNFT = await hre.ethers.getContractFactory("TreeNFT");
        const TreeAuditorRegistry = await hre.ethers.getContractFactory("TreeAuditorRegistry");
        const TreeController = await hre.ethers.getContractFactory("TreeController");

        externalNFT = await TreeNFT.deploy();
        treeNFT = await TreeNFT.deploy();
        auditorRegistry = await TreeAuditorRegistry.deploy();
        treeController = await TreeController.deploy(treeNFT.address, auditorRegistry.address);
    });

    it("Should be able to add NFT", async function () {
        const [signer] = await ethers.getSigners();

        const mintTx = await externalNFT.safeMint(signer.address, "", ethers.utils.solidityPack(['bool'], [true]));
        const mintReceipt = await mintTx.wait();

        const mintEvent = mintReceipt.events?.find(e => e.event === 'Transfer');
        const tokenId = mintEvent?.args!['tokenId'];

        const approveTx = await externalNFT.approve(treeController.address, tokenId);
        await approveTx.wait();

        const treeNumber = 1000;
        const addTx = await treeController.addNFT(externalNFT.address, tokenId, treeNumber);
        await addTx.wait();

        const isOwner = await treeController.checkTreeOwner(signer.address, externalNFT.address, tokenId);

        expect(isOwner).to.equal(true);
    });

    it("Should be able to mint NFT", async function () {
        const [signer] = await ethers.getSigners();

        const treeNumber = 1000;

        const mintTx = await treeController.mintNFT(treeNumber, "");
        const mintReceipt = await mintTx.wait();

        const mintEvent = mintReceipt.events?.find(e => e.event === 'TreeAdded');
        const tokenId = mintEvent?.args!['tokenId'];

        const isOwner = await treeController.checkTreeOwner(signer.address, treeNFT.address, tokenId);

        expect(isOwner).to.equal(true);
    });

    it("Should be able to withdraw NFT", async function () {
        const [signer] = await ethers.getSigners();

        const treeNumber = 1000;

        const mintTx = await treeController.mintNFT(treeNumber, "");
        const mintReceipt = await mintTx.wait();

        const mintEvent = mintReceipt.events?.find(e => e.event === 'TreeAdded');
        const tokenId = mintEvent?.args!['tokenId'];

        const withdrawTx = await treeController.withdraw(treeNFT.address, tokenId);
        await withdrawTx.wait();

        const balance = await treeNFT.balanceOf(signer.address);

        expect(balance).to.equal(1);
    });

    it("Should be able to transfer tree", async function () {
        const [, signer2] = await ethers.getSigners();

        const treeNumber = 1000;

        const mintTx = await treeController.mintNFT(treeNumber, "");
        const mintReceipt = await mintTx.wait();

        const mintEvent = mintReceipt.events?.find(e => e.event === 'TreeAdded');
        const tokenId = mintEvent?.args!['tokenId'];

        const transferTx = await treeController.transfer(signer2.address, treeNFT.address, tokenId);
        await transferTx.wait();

        const isOwner = await treeController.checkTreeOwner(signer2.address, treeNFT.address, tokenId);

        expect(isOwner).to.equal(true);
    });

    it("Should be able to transfer tree with approval and transferFrom", async function () {
        const [signer1, signer2] = await ethers.getSigners();

        const treeNumber = 1000;

        const mintTx = await treeController.mintNFT(treeNumber, "");
        const mintReceipt = await mintTx.wait();

        const mintEvent = mintReceipt.events?.find(e => e.event === 'TreeAdded');
        const tokenId = mintEvent?.args!['tokenId'];

        const approveTx = await treeController.approve(signer2.address, treeNFT.address, tokenId);
        await approveTx.wait();

        const transferTx = await treeController.connect(signer2).transferFrom(signer1.address, signer2.address, treeNFT.address, tokenId);
        await transferTx.wait();

        const isOwner = await treeController.checkTreeOwner(signer2.address, treeNFT.address, tokenId);

        expect(isOwner).to.equal(true);
    });

    it("Should be able to transfer with approveAll and transferFrom", async function () {
        const [signer1, signer2, marketplace] = await ethers.getSigners();

        const treeNumber = 1000;

        const mintTx = await treeController.mintNFT(treeNumber, "");
        const mintReceipt = await mintTx.wait();

        const mintEvent = mintReceipt.events?.find(e => e.event === 'TreeAdded');
        const tokenId = mintEvent?.args!['tokenId'];

        const approveTx = await treeController.setApprovalForAll(marketplace.address, true);
        await approveTx.wait();

        const transferTx = await treeController.connect(marketplace).transferFrom(signer1.address, signer2.address, treeNFT.address, tokenId);
        await transferTx.wait();

        const isOwner = await treeController.checkTreeOwner(signer2.address, treeNFT.address, tokenId);

        expect(isOwner).to.equal(true);
    });

    it("Should be able to audit", async function () {
        const [, auditor] = await ethers.getSigners();

        const treeNumber = 1000;

        const mintTx = await treeController.mintNFT(treeNumber, "");
        const mintReceipt = await mintTx.wait();

        const mintEvent = mintReceipt.events?.find(e => e.event === 'TreeAdded');
        const tokenId = mintEvent?.args!['tokenId'];

        await auditorRegistry.addAuditor(auditor.address);

        await expect(treeController.connect(auditor).audit(treeNFT.address, tokenId, treeNumber)).to.emit(treeController, "TreeAudited")
    });


    it("Should revert if normal user make an audit", async function () {
        const [, fakeAuditor] = await ethers.getSigners();

        const treeNumber = 1000;

        const mintTx = await treeController.mintNFT(treeNumber, "");
        const mintReceipt = await mintTx.wait();

        const mintEvent = mintReceipt.events?.find(e => e.event === 'TreeAdded');
        const tokenId = mintEvent?.args!['tokenId'];

        await expect(treeController.connect(fakeAuditor).audit(treeNFT.address, tokenId, treeNumber)).to.revertedWith("You are not an auditor");
    });

});