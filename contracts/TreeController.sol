// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./interfaces/ITreeNFT.sol";
import "./interfaces/ITreeController.sol";
import "./interfaces/ITreeAuditorRegistry.sol";

contract TreeController is ITreeController, IERC721Receiver {
    event TreeAdded(
        address indexed owner,
        address indexed nftAddress,
        uint256 tokenId,
        uint256 treeNumber
    );

    event TreeApproved(
        address indexed owner,
        address indexed operator,
        address indexed nftAddress,
        uint256 tokenId
    );

    event ApprovedForAll(
        address indexed owner,
        address indexed operator,
        bool indexed approved
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

    mapping(uint256 => address) private _treeApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    modifier isTreeOwner(address _nftAddress, uint256 _tokenId) {
        require(
            checkTreeOwner(msg.sender, _nftAddress, _tokenId),
            "Is not tree owner"
        );
        _;
    }

    modifier isApproved(
        address _nftAddress,
        uint256 _tokenId,
        address _owner
    ) {
        require(
            checkTreeOwner(msg.sender, _nftAddress, _tokenId) ||
                getApproved(_nftAddress, _tokenId) == msg.sender ||
                isApprovedForAll(_owner, msg.sender),
            "Is not tree owner nor approved operator"
        );
        _;
    }

    constructor(address treeNFT_, address auditorRegistry_) {
        _treeNFT = ITreeNFT(treeNFT_);
        _auditorRegistry = ITreeAuditorRegistry(auditorRegistry_);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        // unused variables
        operator;
        from;
        tokenId;

        bool isSafe = abi.decode(data, (bool));
        require(isSafe, "Do not safe transfer");
        return IERC721Receiver.onERC721Received.selector;
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
            _tokenId,
            abi.encode(true)
        );

        uint256 treeId = _addTree(_nftAddress, _tokenId);

        emit TreeAdded(msg.sender, _nftAddress, _tokenId, _treeNumber);

        return treeId;
    }

    function mintNFT(
        uint256 _treeNumber,
        string memory _uri
    ) public override returns (uint256) {
        uint256 tokenId = _treeNFT.safeMint(
            address(this),
            _uri,
            abi.encode(true)
        );
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

    function approve(
        address _to,
        address _nftAddress,
        uint256 _tokenId
    ) external override {
        uint256 treeId = getTreeId(_nftAddress, _tokenId);
        address owner = _ownerOf[treeId];

        require(_to != owner, "Cannot approve to owner");
        require(msg.sender == owner, "Must be called by owner");

        _treeApprovals[treeId] = _to;

        emit TreeApproved(msg.sender, _to, _nftAddress, _tokenId);
    }

    function setApprovalForAll(
        address _operator,
        bool _approved
    ) external override {
        require(msg.sender != _operator, "Cannot approve to caller");
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovedForAll(msg.sender, _operator, _approved);
    }

    function transfer(
        address _to,
        address _nftAddress,
        uint256 _tokenId
    ) external override isTreeOwner(_nftAddress, _tokenId) {
        _transferFrom(msg.sender, _to, _nftAddress, _tokenId);
    }

    function transferFrom(
        address _from,
        address _to,
        address _nftAddress,
        uint256 _tokenId
    ) external override isApproved(_nftAddress, _tokenId, _from) {
        _transferFrom(_from, _to, _nftAddress, _tokenId);
    }

    function _transferFrom(
        address _from,
        address _to,
        address _nftAddress,
        uint256 _tokenId
    ) private {
        require(_to != address(0), "Cannot transfer to null address");
        uint256 treeId = getTreeId(_nftAddress, _tokenId);
        _ownerOf[treeId] = _to;

        delete _treeApprovals[treeId];

        emit TreeTransferred(_from, _to, _nftAddress, _tokenId);
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

        delete _treeApprovals[treeId];

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

    function isApprovedForAll(
        address owner,
        address operator
    ) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function getApproved(
        address _nftAddress,
        uint256 _tokenId
    ) public view virtual override returns (address) {
        uint256 treeId = getTreeId(_nftAddress, _tokenId);
        require(
            !checkTreeOwner(address(0), _nftAddress, _tokenId),
            "Tree has no owner"
        );

        return _treeApprovals[treeId];
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
}
