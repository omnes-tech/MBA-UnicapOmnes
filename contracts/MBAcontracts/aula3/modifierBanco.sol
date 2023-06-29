// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


contract BancoModificadores{

//variáveis globais e estáveis
address public donoContrato;
uint public valorMinDeposito = 1 ether;
bool public pause;

mapping(address => uint256) public Saldo;
mapping(address => bool) SaiudoBC3W;

constructor() {
    donoContrato = msg.sender; //0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
}

function depositar()external payable Pausado BCbaniu{
    require(msg.value >= valorMinDeposito, "o valor minimo tem que ser 1 ether");
    uint256 fee = msg.value/100 *2; //2%
    uint ContratobancoCliente = msg.value - fee;
    Saldo[msg.sender] += ContratobancoCliente;

    //Regras de transferencia dos valores
    payable(donoContrato).transfer(fee);
    payable(address(this)).transfer(ContratobancoCliente);

}

receive() external payable{
}

//vai retirar o valor todo que está no contrato
function RetirarValorDonoBanco() external payable Pausado SomenteDono{
    payable(msg.sender).transfer(address(this).balance);
}

function SairdoBanco() external payable Pausado{
    require(msg.value <= Saldo[msg.sender], "ta querendo mais?? Pode nao");
    uint meuSaldoTodo = Saldo[msg.sender];
    SaiudoBC3W[msg.sender]=true;
    payable(msg.sender).transfer(meuSaldoTodo);
}

function pausarDespausar(bool _booliana)external SomenteDono {
    pause = _booliana;
}


modifier SomenteDono(){
require(msg.sender == donoContrato, "voce nao e o Dono");
_;
}

modifier Pausado(){
    require(!pause, "contrato pausado"); //se não for falso -- si ne qua non
    _;
}

modifier BCbaniu(){
    require(!SaiudoBC3W[msg.sender], "Cancelou e raspou a conta se deu mal"); //se não for falso
    _;
}



}