// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "erc721a/contracts/ERC721A.sol";
import "./IERC721R.sol";

contract ERC721RExample is ERC721A, IERC721R, Ownable, Multicall {
    uint256 public constant maxMintSupply = 8000;
    uint256 public constant mintPrice = 0.1 ether;
    uint256 public constant refundPeriod = 300000;

    // Sale Status
    bool public publicSaleActive;
    bool public presaleActive;

    address public refundAddress;
    uint256 public constant maxUserMintAmount = 5;

    mapping(uint256 => uint256) public refundEndBlockNumbers;
    uint256 public presaleRefundEndBlockNumber;
    uint256 public refundEndBlockNumber;
    mapping(uint256 => bool) public hasRefunded; // users can search if the NFT has been refunded
    mapping(uint256 => bool) public isOwnerMint; // if the NFT was freely minted by owner

    string private baseURI;

    constructor() ERC721A("ERC721RExample", "ERC721R") {
        refundAddress = address(this);
        refundEndBlockNumber = block.number + refundPeriod;
        presaleRefundEndBlockNumber = refundEndBlockNumber;
    }

    function preSaleMint(uint256 quantity) external payable {
        require(presaleActive, "Presale is not active");
        require(msg.value == quantity * mintPrice, "Value");
        require(_numberMinted(msg.sender) + quantity <= maxUserMintAmount, "Max amount");
        require(_totalMinted() + quantity <= maxMintSupply, "Max mint supply");

        _safeMint(msg.sender, quantity);
    }

    function publicSaleMint(uint256 quantity) external payable {
        require(publicSaleActive, "Public sale is not active");
        require(msg.value >= quantity * mintPrice, "Not enough eth sent");
        require(_numberMinted(msg.sender) + quantity <= maxUserMintAmount, "Over mint limit");
        require(_totalMinted() + quantity <= maxMintSupply, "Max mint supply reached");

        _safeMint(msg.sender, quantity);
        refundEndBlockNumber = block.number + refundPeriod;
        for (uint256 i = _nextTokenId() - quantity; i < _nextTokenId(); i++) {
            refundEndBlockNumbers[i] = refundEndBlockNumber;
        }
    }

    function ownerMint(uint256 quantity) external onlyOwner {
        require(_totalMinted() + quantity <= maxMintSupply, "Max mint supply reached");
        _safeMint(msg.sender, quantity);

        for (uint256 i = _nextTokenId() - quantity; i < _nextTokenId(); i++) {
            isOwnerMint[i] = true;
        }
    }

    function refund(uint256 tokenId) external override {
        require(block.number < refundDeadlineOf(tokenId), "Refund expired");
        require(msg.sender == ownerOf(tokenId), "Not token owner");

        hasRefunded[tokenId] = true;
        transferFrom(msg.sender, refundAddress, tokenId);

        uint256 refundAmount = refundOf(tokenId);
        Address.sendValue(payable(msg.sender), refundAmount);
    }

    function refundDeadlineOf(uint256 tokenId) public view override returns (uint256) {
        if (isOwnerMint[tokenId]) {
            return 0;
        }
        if (hasRefunded[tokenId]) {
            return 0;
        }
        return refundEndBlockNumbers[tokenId];
    }

    function refundOf(uint256 tokenId) public view override returns (uint256) {
        if (isOwnerMint[tokenId]) {
            return 0;
        }
        if (hasRefunded[tokenId]) {
            return 0;
        }
        return mintPrice;
    }

    function withdraw() external onlyOwner {
        require(block.timestamp > refundEndBlockNumber, "Refund period not over");
        uint256 balance = address(this).balance;
        Address.sendValue(payable(owner()), balance);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        baseURI = uri;
    }

    function togglePresaleStatus() external onlyOwner {
        presaleActive = !presaleActive;
    }

    function togglePublicSaleStatus() external onlyOwner {
        publicSaleActive = !publicSaleActive;
    }

    function _leaf(address _account) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account));
    }

    function _isAllowlisted(
        address _account,
        bytes32[] calldata _proof,
        bytes32 _root
    ) internal pure returns (bool) {
        return MerkleProof.verify(_proof, _root, _leaf(_account));
    }
}
