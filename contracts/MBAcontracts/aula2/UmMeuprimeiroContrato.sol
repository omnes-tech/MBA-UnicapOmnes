// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


contract meuPrimeiroContract{

    //variáveis globais
    uint256 private minhaIdade;
    string public meuNome;
    address public meuEndereco;

    function setarMeuNome(string memory _meunome)external{
        meuNome = _meunome;
    }

    function setarMinhaidade(uint256 _idade)external {
        minhaIdade=_idade;
    }

    function meuendereco()external{
        meuEndereco=msg.sender;
    }



}