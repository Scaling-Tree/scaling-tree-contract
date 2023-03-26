# Scaling Tree

<p align="center">
  <img src="https://scalingtree.0xwa.run/_next/image?url=%2Fimages%2Flogo_scaling_tree.png&w=640&q=75" width="200" alt="Scaling tree logo" />
</p>


## Getting Started

```bash
# install dependencies
npm i
# run development server
npx hardhat run scripts/deploy/tree-controller.ts --network <network>
```
### Smart contracts
There are 4 completed smart contracts (and 2 upcoming contracts) in this project:
1. TreeNFT - The NFT represents tree ownership. User can mint NFT using this smart contract. Please note that this project can plug in with existing tree NFT projects, such as, Coorest, NFTrees, etc. User can add those NFTs to this project.
2. TreeDAO - The DAO Smart contract for executing DAO transactions, such as, adding and removing tree auditors
3. TreeAuditorRegistry - The contract for storing list of tree auditors. DAO will vote for adding or removing auditors in this contract.
4. TreeController - The main smart contract that keeps track of tree ownership. People can add, mint, audit, withdraw, and transfer NFT using this contract.
5. TreeMarketplace (future work) - The marketplace for trading TreeNFT.
6. TreeDAOTreasury (future work) - The smart contract for keeping DAO treasury that will be used for all expenses to maintain the system.

### Repositories

Here is the list of repositories:

Frontend - [https://github.com/Scaling-Tree/scaling-tree-frontend](https://github.com/Scaling-Tree/scaling-tree-frontend)

Smart contract - [https://github.com/Scaling-Tree/scaling-tree-contract](https://github.com/Scaling-Tree/scaling-tree-contract)

Subgraph - [https://github.com/Scaling-Tree/scaling-tree-subgraph](https://github.com/Scaling-Tree/scaling-tree-subgraph)