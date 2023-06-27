// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "./Ownable.sol";

contract SouDono is Ownable {

    constructor() Ownable(msg.sender){

    }

    //vou substituir a função do contrato abstrato que retorna o owner
    function retoranarDono()external view returns(address){
        //não posso chamar direto a variável sendo ela privada
        //-- Ownable._owner
        //mas podemos chamar a função q retorna o endereço
        return owner();//como a owner já é pública não teria necessidade de fazer o retorno dela
    }

    //posso subistituir a função do contrato abstrato utilizando minhas prórias definições
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        //tomar muito cuidado quando usar o override
        //transferOwnership(newOwner);
     }

}