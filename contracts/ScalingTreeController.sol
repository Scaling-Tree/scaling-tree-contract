// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./TreeNFT.sol";

contract ScalingTreeController {
    event TreeAdded(
        address indexed owner,
        address indexed nftAddress,
        uint256 tokenId,
        uint256 treeNumber
    );

    event TreeTransferred(
        address indexed from,
        address indexed to,
        address indexed nftAddress,
        uint256 tokenId
    );

    event TreeWithdrew(
        address indexed to,
        address indexed nftAddress,
        uint256 tokenId
    );

    event TreeAudited(
        address indexed auditor,
        address indexed nftAddress,
        uint256 tokenId,
        uint256 treeNumber
    );

    struct Tree {
        address nftAddress;
        uint256 tokenId;
        bool isActive;
    }

    mapping(uint256 => Tree) public treeRecords;
    mapping(uint256 => bool) public treeInitialized;
    mapping(uint256 => address) public ownerOf;
    TreeNFT public treeNFT;

    modifier isTreeOwner(address _nftAddress, uint256 _tokenId) {
        require(
            checkTreeOwner(msg.sender, _nftAddress, _tokenId),
            "Is not tree owner"
        );
        _;
    }

    constructor(address _treeNFT) {
        _validateNFTContract(_treeNFT);

        treeNFT = TreeNFT(_treeNFT);
    }

    function addNFT(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _treeNumber
    ) public returns (uint256) {
        require(
            checkTreeOwner(address(0), _nftAddress, _tokenId),
            "Already has owner"
        );

        ERC721(_nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId
        );

        uint256 treeId = _addTree(_nftAddress, _tokenId);

        emit TreeAdded(msg.sender, _nftAddress, _tokenId, _treeNumber);

        return treeId;
    }

    function mintNFT(
        uint256 _treeNumber,
        string memory _uri
    ) public returns (uint256) {
        uint256 tokenId = treeNFT.safeMint(address(this), _uri);
        uint256 treeId = _addTree(address(treeNFT), tokenId);

        emit TreeAdded(msg.sender, address(treeNFT), tokenId, _treeNumber);

        return treeId;
    }

    function audit(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _treeNumber
    ) public returns (uint256) {
        // require(isAuditor, "You are not an auditor");
        uint256 treeId = getTreeId(_nftAddress, _tokenId);
        require(
            !checkTreeOwner(address(0), _nftAddress, _tokenId),
            "Tree has no owner"
        );
        emit TreeAudited(msg.sender, _nftAddress, _tokenId, _treeNumber);
        return treeId;
    }

    function transfer(
        address _nftAddress,
        uint256 _tokenId,
        address to
    ) public isTreeOwner(_nftAddress, _tokenId) {
        require(to != address(0), "Cannot transfer to null address");
        uint256 treeId = getTreeId(_nftAddress, _tokenId);
        ownerOf[treeId] = to;

        emit TreeTransferred(msg.sender, to, _nftAddress, _tokenId);
    }

    function withdraw(
        address _nftAddress,
        uint256 _tokenId
    ) public isTreeOwner(_nftAddress, _tokenId) returns (uint256) {
        uint256 treeId = getTreeId(_nftAddress, _tokenId);
        treeRecords[treeId].isActive = false;
        ownerOf[treeId] = address(0);

        ERC721(_nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

        emit TreeWithdrew(msg.sender, address(treeNFT), _tokenId);

        return treeId;
    }

    function getTreeId(
        address _nftAddress,
        uint256 _tokenId
    ) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(_nftAddress, _tokenId)));
    }

    function _addTree(
        address _nftAddress,
        uint256 _tokenId
    ) internal returns (uint256) {
        uint256 treeId = getTreeId(_nftAddress, _tokenId);
        bool isInitialized = treeInitialized[treeId];

        if (!isInitialized) {
            Tree memory tree = Tree(_nftAddress, _tokenId, true);

            treeRecords[treeId] = tree;
            ownerOf[treeId] = msg.sender;
            treeInitialized[treeId] = true;
        } else {
            ownerOf[treeId] = msg.sender;
            treeRecords[treeId].isActive = true;
        }

        return treeId;
    }

    function checkTreeOwner(
        address _owner,
        address _nftAddress,
        uint256 _tokenId
    ) public view returns (bool) {
        uint256 treeId = getTreeId(_nftAddress, _tokenId);
        return ownerOf[treeId] == _owner;
    }

    function _validateNFTContract(
        address _nftAddress
    ) private view returns (bool) {
        ERC721(_nftAddress).tokenURI(0);
        return true;
    }
}
