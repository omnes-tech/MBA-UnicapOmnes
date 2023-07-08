//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// These libraries were replaced and contract extended with Initializable, UUPSUpgradeable
contract UpgradeMBAV2 is Initializable, UUPSUpgradeable, ERC1155Upgradeable, OwnableUpgradeable {
    mapping(uint256 => string) public tokenURI;
    uint256 public tokenId;

    mapping(address => bool) allowList;

    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __ERC1155_init("");
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address _newImplementation) internal override onlyOwner {}
    /*
    A função _authorizeUpgrade(address _newImplementation) é usada em contratos inteligentes que usam o padrão UUPSUpgradeable 
    para autorizar atualizações do contrato inteligente.
    Essa função é chamada sempre que uma atualização do contrato inteligente é proposta. 
    Ela verifica se a conta que está propondo a atualização tem permissão para fazê-lo. 
    Se a conta tiver permissão, 
    a atualização será autorizada e o contrato inteligente será atualizado.
    */

    function mint(
        uint256 amount,
        string memory _tokenURI,
        bytes memory data
    ) public returns (uint256) {
        uint256 _tokenId = tokenId;
        tokenURI[_tokenId] = _tokenURI;
        _mint(msg.sender, _tokenId, amount, data);
        tokenId++;
        return _tokenId;
    }

    function mint10() public Allowlist returns (uint256){
        uint256 _tokenId = tokenId;
        _mint(msg.sender, _tokenId, 10, "0x00");
        tokenId++;
        return _tokenId;
    } //id começa no 0

    function uri(uint256 _tokenId) public view override returns (string memory) {
        return tokenURI[_tokenId];
    }

    function setAllow(address _endereco, bool _allow) external onlyOwner {
        allowList[_endereco] = _allow;
    }

    modifier Allowlist(){
        require(allowList[msg.sender] == true, "nao e permitido");
        _;
    }
}
