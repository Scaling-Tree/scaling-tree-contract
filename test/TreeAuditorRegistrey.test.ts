import { expect } from "chai";
import hre, { ethers } from "hardhat";
import { TreeAuditorRegistry } from "../typechain-types";

describe("TreeAuditorRegistry", function () {

    let auditorRegistry: TreeAuditorRegistry;

    this.beforeEach(async () => {
        const TreeAuditorRegistry = await hre.ethers.getContractFactory("TreeAuditorRegistry");
        auditorRegistry = await TreeAuditorRegistry.deploy();
    })

    it("Should be able to check auditor", async function () {
        const [, notAuditor] = await ethers.getSigners();
        expect(await auditorRegistry.isAuditor(notAuditor.address)).to.equal(false);
    });

    it("Should be able to add auditor", async function () {
        const [, auditor] = await ethers.getSigners();
        const tx = await auditorRegistry.addAuditor(auditor.address);
        await tx.wait();
        expect(await auditorRegistry.isAuditor(auditor.address)).to.equal(true);
    });

    it("Should be able to remove auditor", async function () {
        const [, auditor] = await ethers.getSigners();

        const addTx = await auditorRegistry.addAuditor(auditor.address);
        await addTx.wait();

        const removeTx = await auditorRegistry.removeAuditor(auditor.address);
        await removeTx.wait();

        // assert that the value is correct
        expect(await auditorRegistry.isAuditor(auditor.address)).to.equal(false);
    });
});