// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//token
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//código retirado do wizard e implementado a possibilidade de mintar com o token ERC20
contract MyToken is ERC721, ERC721Burnable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    IERC20 public AcessToken;

    constructor(address _token) ERC721("NFT-OnlyAcess", "NFTAcess") {
        AcessToken = IERC20(_token);
    }

    function safeMint(address to) public  {
        //conferimos se a carteira tem um ou mais de um token de acesso
        require(AcessToken.balanceOf(msg.sender)>= 1, "Nao tem Token obrigatorio de acesso");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
}

