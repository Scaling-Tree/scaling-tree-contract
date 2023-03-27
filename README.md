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

### Smart contract addresses
#### Goerli
```json
{
  "TreeNFT": "0x16b41e517D8Db1260683e421b5eA6472Fb4D234a",
  "TreeAuditorRegistry": "0x8d5C8E9AD6865cB80Cb86Cc4Ee7643062AB0329B",
  "TreeController": "0xB0d4C0bc1D323abe1b043D9f26E9eCB0f2F45f4F",
  "NFT": "0xA23F346eCbBd1f1D503AE772CDA27d2433F740Da"
}
```
#### Gnosis
```json
{
  "TreeNFT": "0xeDD75C30CD82dE8B321B6B1Ce7d2040aCA17d9a7",
  "TreeAuditorRegistry": "0x12131300Ca945c57DAB73eDd39F268E7849Aedc9",
  "TreeController": "0xA619D59Bc56a9193f0dDfd8c79d6beeBBD4e5423"
}
```
#### Optimism
```json
{
  "TreeNFT": "0xeDD75C30CD82dE8B321B6B1Ce7d2040aCA17d9a7",
  "TreeAuditorRegistry": "0x12131300Ca945c57DAB73eDd39F268E7849Aedc9",
  "TreeController": "0xA619D59Bc56a9193f0dDfd8c79d6beeBBD4e5423"
}
```


### Repositories

Here is the list of repositories:

Frontend - [https://github.com/Scaling-Tree/scaling-tree-frontend](https://github.com/Scaling-Tree/scaling-tree-frontend)

Smart contract - [https://github.com/Scaling-Tree/scaling-tree-contract](https://github.com/Scaling-Tree/scaling-tree-contract)

Subgraph - [https://github.com/Scaling-Tree/scaling-tree-subgraph](https://github.com/Scaling-Tree/scaling-tree-subgraph)