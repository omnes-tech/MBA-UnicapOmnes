// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


contract ExemploSimples{

//todos os dados armazenados nessa estrutura
struct MeusDados {
        string meuNome;
        string sobreNome;
        address endereco;
    }

//eu declaro dessa forma que a estrutura será publica e chamada de outra forma
MeusDados public consultaDado;

//inserir os dados na estrutura
function inserirDados(string memory _meuNome, 
string memory _sobreNome)external{
    consultaDado = MeusDados({
        meuNome: _meuNome,
        sobreNome: _sobreNome,
        endereco: msg.sender
     });
}

 }