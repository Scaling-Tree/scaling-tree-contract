// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IScalingTreeController {
    struct Tree {
        address nftAddress;
        uint256 tokenId;
        bool isActive;
    }

    function treeRecords(uint256 treeId) external view returns (Tree memory);

    function treeInitialized(uint256 treeId) external view returns (bool);

    function ownerOf(uint256 treeId) external view returns (address);

    function treeNFT() external view returns (address);

    function auditorRegistry() external view returns (address);

    function addNFT(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _treeNumber
    ) external returns (uint256);

    function mintNFT(
        uint256 _treeNumber,
        string memory _uri
    ) external returns (uint256);

    function audit(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _treeNumber
    ) external returns (uint256);

    function transfer(
        address _nftAddress,
        uint256 _tokenId,
        address to
    ) external;

    function withdraw(
        address _nftAddress,
        uint256 _tokenId
    ) external returns (uint256);

    function getTreeId(
        address _nftAddress,
        uint256 _tokenId
    ) external pure returns (uint256);

    function checkTreeOwner(
        address _owner,
        address _nftAddress,
        uint256 _tokenId
    ) external view returns (bool);
}
