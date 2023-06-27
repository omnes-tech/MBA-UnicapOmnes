// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


// Definindo uma interface
interface ContratoInterface {
    //não posso inserir variáveias:
    //uint256 valores;

    function depositar(uint256 valor) external;
    function sacar(uint256 valor) external;
    function consultarSaldo() external view returns (uint256);

//nem funções que modifiquem o estado
//function depo()external{

//}

}