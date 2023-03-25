// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./interfaces/ITreeNFT.sol";
import "./interfaces/IScalingTreeController.sol";
import "./interfaces/ITreeAuditorRegistry.sol";

contract ScalingTreeController is IScalingTreeController {
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

    mapping(uint256 => Tree) private _treeRecords;
    mapping(uint256 => bool) private _treeInitialized;
    mapping(uint256 => address) private _ownerOf;
    ITreeNFT private _treeNFT;
    ITreeAuditorRegistry private _auditorRegistry;

    modifier isTreeOwner(address _nftAddress, uint256 _tokenId) {
        require(
            checkTreeOwner(msg.sender, _nftAddress, _tokenId),
            "Is not tree owner"
        );
        _;
    }

    constructor(address treeNFT_, address auditorRegistry_) {
        _validateNFTContract(treeNFT_);

        _treeNFT = ITreeNFT(treeNFT_);
        _auditorRegistry = ITreeAuditorRegistry(auditorRegistry_);
    }

    function addNFT(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _treeNumber
    ) public override returns (uint256) {
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
    ) public override returns (uint256) {
        uint256 tokenId = _treeNFT.safeMint(address(this), _uri);
        uint256 treeId = _addTree(address(_treeNFT), tokenId);

        emit TreeAdded(msg.sender, address(_treeNFT), tokenId, _treeNumber);

        return treeId;
    }

    function audit(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _treeNumber
    ) public override returns (uint256) {
        require(
            _auditorRegistry.isAuditor(msg.sender),
            "You are not an auditor"
        );
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
    ) public override isTreeOwner(_nftAddress, _tokenId) {
        require(to != address(0), "Cannot transfer to null address");
        uint256 treeId = getTreeId(_nftAddress, _tokenId);
        _ownerOf[treeId] = to;

        emit TreeTransferred(msg.sender, to, _nftAddress, _tokenId);
    }

    function withdraw(
        address _nftAddress,
        uint256 _tokenId
    ) public override isTreeOwner(_nftAddress, _tokenId) returns (uint256) {
        uint256 treeId = getTreeId(_nftAddress, _tokenId);
        _treeRecords[treeId].isActive = false;
        _ownerOf[treeId] = address(0);

        ERC721(_nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

        emit TreeWithdrew(msg.sender, address(_treeNFT), _tokenId);

        return treeId;
    }

    function getTreeId(
        address _nftAddress,
        uint256 _tokenId
    ) public pure override returns (uint256) {
        return uint256(keccak256(abi.encode(_nftAddress, _tokenId)));
    }

    function checkTreeOwner(
        address _owner,
        address _nftAddress,
        uint256 _tokenId
    ) public view override returns (bool) {
        uint256 treeId = getTreeId(_nftAddress, _tokenId);
        return _ownerOf[treeId] == _owner;
    }

    function treeRecords(
        uint256 _treeId
    ) external view override returns (Tree memory) {
        return _treeRecords[_treeId];
    }

    function treeInitialized(
        uint256 _treeId
    ) external view override returns (bool) {
        return _treeInitialized[_treeId];
    }

    function ownerOf(uint256 _treeId) external view override returns (address) {
        return _ownerOf[_treeId];
    }

    function treeNFT() external view override returns (address) {
        return address(_treeNFT);
    }

    function auditorRegistry() external view override returns (address) {
        return address(_auditorRegistry);
    }

    function _addTree(
        address _nftAddress,
        uint256 _tokenId
    ) internal returns (uint256) {
        uint256 treeId = getTreeId(_nftAddress, _tokenId);
        bool isInitialized = _treeInitialized[treeId];

        if (!isInitialized) {
            Tree memory tree = Tree(_nftAddress, _tokenId, true);

            _treeRecords[treeId] = tree;
            _ownerOf[treeId] = msg.sender;
            _treeInitialized[treeId] = true;
        } else {
            _ownerOf[treeId] = msg.sender;
            _treeRecords[treeId].isActive = true;
        }

        return treeId;
    }

    function _validateNFTContract(
        address _nftAddress
    ) private view returns (bool) {
        ERC721(_nftAddress).tokenURI(0);
        return true;
    }
}
