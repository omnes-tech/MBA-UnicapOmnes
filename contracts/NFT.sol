// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

import "./solmate/ERC721.sol";
import { Strings } from "./openzeppelin/Strings.sol";
import "./openzeppelin/Ownable.sol";
import "./openzeppelin/Context.sol";

error MintPriceNotPaid();
error MaxSupply();
error NonExistentTokenURI();
error WithdrawTransfer();

contract NFT is ERC721, Ownable {
    using Strings for uint256;
    string public generalURI;
    string public baseURI;
    uint256 public currentTokenId;
    uint256 public constant TOTAL_SUPPLY = 10_000;

    //omnes protocol
    uint256 public price;
    uint256 public maxDiscount;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _generalURI
    ) ERC721(_name, _symbol) {
        generalURI = _generalURI;
    }

    function mintTo(address recipient) public payable returns (uint256) {
        if (msg.value < price - ((price * maxDiscount) / 10000)) {
            revert MintPriceNotPaid();
        }
        uint256 newTokenId = ++currentTokenId;
        if (newTokenId > TOTAL_SUPPLY) {
            revert MaxSupply();
        }
        _safeMint(recipient, newTokenId);
        return newTokenId;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) {
            revert NonExistentTokenURI();
        }
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : generalURI;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function setMaxdiscont(uint256 _maxDiscont) external onlyOwner {
        maxDiscount = _maxDiscont;
    }

    function setGeneralURI(string memory _generalURI) external onlyOwner {
        generalURI = _generalURI;
    }

    function withdrawPayments(address payable payee) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool transferTx, ) = payee.call{ value: balance }("");
        if (!transferTx) {
            revert WithdrawTransfer();
        }
    }
}
