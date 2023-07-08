// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";
import "./IERC721R.sol";

contract ERC721RExample is ERC721A, IERC721R, Ownable {
    uint256 public constant maxMintSupply = 8000;
    uint256 public constant mintPrice = 1 ether;
    uint256 public constant refundPeriod = 30 seconds; //tempo para fazer o refound

    // Sale Status -- status de vendas
    bool public publicSaleActive;
    bool public presaleActive;

    address public refundAddress; //--para onde vai os NFTs que são devolvidos
    uint256 public constant maxUserMintAmount = 5; //--numero máximo de mint por usuário

    mapping(uint256 => uint256) public refundEnd;//mapping referente ao ID do refund e o tempo para realizar
    mapping(address => uint256) public valueRefund;//valor de refound para o endereço

    uint256 public presaleRefundEnd;//tempo definido para o refund na pre sale
    uint256 public refundEndtimestamp;//final do prazo de refound

    mapping(uint256 => bool) public hasRefunded; // users can search if the NFT has been refunded
    mapping(uint256 => bool) public isOwnerMint; // if the NFT was freely minted by owner

    string private baseURI;

    constructor() ERC721A("ERC721RExample", "ERC721R") {
        refundAddress = address(this);
        refundEndtimestamp = block.timestamp + refundPeriod;
        presaleRefundEnd = refundEndtimestamp;
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
        refundEndtimestamp= block.timestamp + refundPeriod;
        valueRefund[msg.sender] += msg.value;

        for (uint256 i = _nextTokenId() - quantity; i < _nextTokenId(); i++) {
            refundEnd[i] = refundEndtimestamp;
        }
    }

    function ownerMint(uint256 quantity) external onlyOwner {
        require(_totalMinted() + quantity <= maxMintSupply, "Max mint supply reached");
        _safeMint(msg.sender, quantity);

    //armazena todos os Ids mintados pelo dono e conseguimos veriicar depois se ele mintou retornando como true
    //O incremento é executado após cada iteração do loop e atualiza o valor da variável de controle.
        for (uint256 i = _nextTokenId() - quantity; i < _nextTokenId(); i++) {
            isOwnerMint[i] = true;
        }
    }

    function refund(uint256 tokenId) external override {
        require(block.timestamp < refundDeadlineOf(tokenId), "Refund expired");
        require(msg.sender == ownerOf(tokenId), "Not token owner");

        hasRefunded[tokenId] = true;
        transferFrom(msg.sender, refundAddress, tokenId);

        uint256 refundAmount = valueRefund[msg.sender];
        payable(msg.sender).transfer(refundAmount);
        valueRefund[msg.sender] = 0;
    }

    function refundDeadlineOf(uint256 tokenId) public view override returns (uint256) {
        if (isOwnerMint[tokenId]) {
            return 0;
        }
        if (hasRefunded[tokenId]) {
            return 0;
        }
        return refundEnd[tokenId];
    }

    function withdraw() external onlyOwner {
        require(block.timestamp > refundEndtimestamp, "Refund period not over");
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
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


}
