// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


contract EnumPedidosMercadoria{

    address public DonoMercadoria;
    address public comprador;
    string[1] public Produto;
    uint256 public valor;
    mapping(address=> string) meuProduto;

    //                   0          1            2         
    enum StatusPedido {Pendente, EmAndamento, Concluido}

    StatusPedido private status;

    event StatusAtualizado(StatusPedido novoStatus);

    constructor(address _comprador, string memory _inserirProduto, uint _valor){
        comprador = _comprador;
        DonoMercadoria = msg.sender;
        Produto[0]=_inserirProduto;
        status = StatusPedido.Pendente;
        valor = _valor;
    }

    function PedirMercadoria(string memory _produto)external payable{
        require(compareStrings(_produto, Produto[0]), "nao temos seu produto");
        require(msg.sender == comprador, "vc nao faz parte desse contrato");
        require(msg.value == valor, "valor do produto errado");
        meuProduto[msg.sender]=_produto;
        status = StatusPedido.EmAndamento;
    }

    function MudarparaPendente(StatusPedido _novostatus)external{
        require(msg.sender == DonoMercadoria, "so pode o dono da mercadoria");
        require(_novostatus != StatusPedido.Concluido, "so pode o dono da mercadoria");
        status = _novostatus;
    }

    function Recebido()external{
        require(msg.sender == comprador, "vc nao faz parte desse contrato");
        status = StatusPedido.Concluido;
    }

    function conferirStatus()external view returns(StatusPedido){
        require(msg.sender == comprador, "vc nao faz parte desse contrato");
        return status;
    }

    //Helpers -- vai chegcar se a string de a encodada vai ser a de b.
    function compareStrings(string memory a, string memory b) internal pure returns(bool){
        return (keccak256(abi.encodePacked(a)) ==  keccak256(abi.encodePacked(b)));
    }

    function sacarValor() external payable {
        require(msg.sender == DonoMercadoria, "so pode o dono da mercadoria");
        require( status == StatusPedido.Concluido, "so pode sacar apos a conclusao");
        payable(msg.sender).transfer(address(this).balance);
    }



}