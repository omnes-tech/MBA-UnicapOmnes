// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

//https://sepolia.etherscan.io/address/0x07efff9655eb67b387e045d44c75f74063cb80db#writeContract

contract eventsVoting {
    uint256 public totalVotos;
    uint256 private limiteVotos = 1;

    mapping(address => uint256) numVotos;
    mapping(address => mapping(address => bool)) permitDelegate;
    //aqui o endereço vai permitir que outro endereço vote por ele.

    event Votou(address indexed enderecoVoto);

    event permitVotar(address indexed delegante, address indexed delegado, bool permit);

    event VotoDelegado(address indexed delegadoVotou);

    function Votar() external maxVotos(msg.sender) {
        numVotos[msg.sender] = 1;
        totalVotos++;
        emit Votou(msg.sender);
    }

    function delegarVoto(address _delegado) external {
        require(!permitDelegate[msg.sender][_delegado], "ja delegou seu voto");
        permitDelegate[msg.sender][_delegado] = true;
        emit permitVotar(msg.sender, _delegado, true);
    }

    function votarPordelegacao(address _delegante) external maxVotos(_delegante) {
        require(permitDelegate[_delegante][msg.sender] = true, "vc nao foi permitido");
        numVotos[_delegante] = 1;
        totalVotos++;
        emit VotoDelegado(msg.sender);
    }

    modifier maxVotos(address _endereco) {
        require(numVotos[_endereco] != limiteVotos, "ja votou amigao ou alguem ja votou");
        _;
    }
}
