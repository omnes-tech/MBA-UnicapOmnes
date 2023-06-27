// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

//NÃO PRECISO OBRIGATORIAMENTE IMPLEMENTAR AS FUNÇÕES NO CONTRATO FILHO
abstract contract Dados {

//posso inserir variáveis 
    string public nome;
    uint256 public idade;

// só pode por EOAS
    function setarNome(string memory _nome) external virtual {
        nome = _nome;
    }

//Qualquer conta, podendo ser contrato ou EOAS
    function setarIdade(uint256 _idade) public virtual {
        idade = _idade;
    }

    function retornarDados() public view virtual returns (string memory, uint){
        return (nome,(idade));
    }
}