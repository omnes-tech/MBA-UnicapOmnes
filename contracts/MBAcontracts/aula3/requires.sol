// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

//Contrato de restrição de endereços, onde somente o
//endereço setado em uma variável estado

contract Restricao {
    address private dono = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    mapping(address => bool) public banido;
    mapping(address => string) public listaNomeEndereco;

    function banirEndereco(address _banido) external {
        require(msg.sender == dono, "nao e o dono");
        banido[_banido] = true;
    }

    function colocarNomenaLista(string memory _nome) external {
        require(banido[msg.sender] == false, "desculpe, esta banido");
        listaNomeEndereco[msg.sender] = _nome;
    }
}
