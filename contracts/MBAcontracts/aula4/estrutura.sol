// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


contract ExemploSimples{

struct MeusDados {
        string meuNome;
        string sobreNome;
        address endereco;
    }

MeusDados public consultaDado;

function inserirDados(string memory _meuNome, 
string memory _sobreNome)external{
    consultaDado = MeusDados({
        meuNome: _meuNome,
        sobreNome: _sobreNome,
        endereco: msg.sender
     });
}

 }