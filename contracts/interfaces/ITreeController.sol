// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface ITreeController {
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

    function getTreeId(
        address _nftAddress,
        uint256 _tokenId
    ) external pure returns (uint256);

    function checkTreeOwner(
        address _owner,
        address _nftAddress,
        uint256 _tokenId
    ) external view returns (bool);

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);

     function getApproved(
        address _nftAddress,
        uint256 _tokenId
    ) external view returns (address);

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

    function approve(
        address _to,
        address _nftAddress,
        uint256 _tokenId
    ) external;

    function setApprovalForAll(address _operator, bool _approved) external;

    function transfer(
        address to,
        address _nftAddress,
        uint256 _tokenId
    ) external;

    function transferFrom(
        address _from,
        address _to,
        address _nftAddress,
        uint256 _tokenId
    ) external;

    function withdraw(
        address _nftAddress,
        uint256 _tokenId
    ) external returns (uint256);
}
