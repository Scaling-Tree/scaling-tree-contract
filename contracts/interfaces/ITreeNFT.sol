// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface ITreeNFT {
    function safeMint(address to, string memory uri, bytes calldata data) external returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
