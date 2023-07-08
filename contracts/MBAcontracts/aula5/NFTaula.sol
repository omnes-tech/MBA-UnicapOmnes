// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9; //expecificação da versão do compilador da linguagem solidity

import "erc721a/contracts/ERC721A.sol"; //Quando usar o Remix importar direto do https://github.com/chiru-labs/ERC721A/blob/main/contracts/ERC721A.sol
import "@openzeppelin/contracts/access/Ownable.sol"; // que permite restrição de que o somente o dono do contrato pode executar determinadas funções
import "@openzeppelin/contracts/security/Pausable.sol"; //e permite pausar determinadas funções
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//import "https://github.com/chiru-labs/ERC721A/blob/main/contracts/ERC721A.sol";

//o ERC721A gera mais eficiencia sendo um dos principais motivos de não utilizar a extenção de enumerable abaixo
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

//Inserir o código no Remix: https://remix.ethereum.org/
//
contract NFTAula is
    ERC721A,
    Pausable,
    Ownable //declaramos todas as importações acima
{
    uint256 public cost; //variável global/estável referente ao custo definido do NFT
    string baseURI; //variável global/estável referente ao metadado do NFT

    error NonExistentToken();

    //metadado: definições de imagem e atributos do NFT
    constructor(
        uint256 _cost,
        string memory _initBaseURI,//https://ipfs.io/ipfs/bafybeib3nlknobtqo2cqqiibcncjxijycgd3i6trvsvr6lonvmp7fxfz6u/
        address _owner
    ) ERC721A("MBA-NFT", "mba") {
        //parametros iniciais antes do deploy do NFT
        setCost(_cost); //setando o custo do contrato
        setBaseURI(_initBaseURI); // setando o metadado devendo ser um link IPFS: 
        //https://ipfs.io/ipfs/bafybeib3nlknobtqo2cqqiibcncjxijycgd3i6trvsvr6lonvmp7fxfz6u/
        _transferOwnership(_owner); // setando o endereço que será o dono do contrato
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI; //função que permite que o dono do contrato possa setar um novo metadado
    }

    function setCost(uint256 _cost) public onlyOwner {
        cost = _cost; //função que permite o dono setar o novo custo do NFT
    }

    function pause() public onlyOwner {
        _pause(); //que permite que o dono pause determinadas funções do contrato
    }

    function unpause() public onlyOwner {
        _unpause(); //que permite que o dono despause determinadas funções do contrato
    }

    //mint do
    function safeMint(address to, uint256 _quantity) public payable whenNotPaused {
        //verifica se não está pausado o contrato e permite passar valores na função
        require(msg.value >= cost, "Insufficient funds!"); //requisição que verifica se o valor enviado na transação pe igual ou maior ao custo do NFT
        _safeMint(to, _quantity); //função importada do ERC721A que registra para onde vai e quantidade do NFT mintado
        //no ERC721A já possue o contabilização no próprio contrato que herdamos
    } // a contagem do padrão ERC721A começa no 0

    function _baseURI() internal view virtual override returns (string memory) {
        //demos o override na função do ERC721A
        return baseURI; // no caso desse padrão devemos sempre inserir o IPFS de uma pasta pq ele
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert NonExistentToken();

        string memory baseURi = _baseURI();
        return
            bytes(baseURi).length != 0
                ? string(abi.encodePacked(baseURi, _toString(tokenId), ".json"))
                : "";
    }

    function withdraw() public payable onlyOwner {
        //função que permite o dono do contrato sacar todos os valores arrecadados da venda primária
        (bool os, ) = payable(owner()).call{ value: address(this).balance }("");
        require(os);
    }
}
