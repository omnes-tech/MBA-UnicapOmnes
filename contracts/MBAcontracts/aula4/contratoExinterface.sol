// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {ContratoInterface} from "./interfaceEx.sol";
import "./abstrato.sol";

// Contrato que usa a interface e contrato abstrato
//os dois tipos de contrato não podem ser implementados (DEPLOYADOS) são só uma base de recursos que podemos ou devemos usar
contract ContratoPrincipal is ContratoInterface, Dados{
    Dados public dados;

    uint valordepositado;

    //podemos importar as definições da interface no contrato principal assim armazenando todos os dados nesse contrato
    function depositar(uint256 valor) external override(ContratoInterface){
        valordepositado += valor;
    }

    function consultarSaldo() external view virtual override returns(uint256){
        return valordepositado;
    }

    //quando utilizamos uma interface devemos chamar todas as funções delimitadas nele 
    //utilizando OVERRIDE
    //mute a função e vejamos que vai aparecer um erro
    function sacar(uint256 valor) external override{
        valordepositado -= valor;
    }

    

    //abstrato -- não conseguimos modificar nada no contrato abstrato

    function setarIdadenoAbstrato(uint256 _idade)external {
        dados.setarIdade(_idade);
    }
    

}