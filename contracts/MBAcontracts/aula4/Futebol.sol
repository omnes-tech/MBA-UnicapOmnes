// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;



import {Math} from "./libraryMath.sol";

contract PartidaFutebol {

    using Math for uint;
    address Arbitro;

    struct Partida {
        string timeCasa;
        string timeVisitante;
        uint256 placarCasa;
        uint256 placarVisitante;
        bool vencedorCasa;
        bool vencedorVisitante;
        bool encerrada;
    }

    mapping(uint256 => Partida) public idPartida;
    mapping(string => uint) public VitoriasCasa;
    mapping(string => uint) public VitoriasVisitantes;
    

    function IniciarPartida(string memory _timeCasa, 
    string memory _timeVisitante, uint _idPartida) public {
        require(!idPartida[_idPartida].encerrada, "A partida ja existe e foi encerrada.");
        idPartida[_idPartida] = Partida({
            timeCasa: _timeCasa,
            timeVisitante: _timeVisitante,
            placarCasa: 0,
            placarVisitante: 0,
            vencedorCasa: false,
            vencedorVisitante: false,
            encerrada: false
        });
        VitoriasCasa[_timeCasa] = 0;
        VitoriasVisitantes[_timeVisitante] = 0;
        Arbitro = msg.sender;
    }



    function atualizarPlacar(uint256 _placarCasa, 
    uint256 _placarVisitante, uint _idPartida) public OnlyArbitro{
        require(!idPartida[_idPartida].encerrada, "A partida ja esta encerrada.");
        idPartida[_idPartida].placarCasa = _placarCasa;
        idPartida[_idPartida].placarVisitante = _placarVisitante;
    }

    function encerrarPartida(uint _idPartida) public OnlyArbitro returns(uint,string memory,bool){
        require(!idPartida[_idPartida].encerrada, "A partida ja esta encerrada.");
        idPartida[_idPartida].encerrada = true;

        //aprendendo a usar a library:
        uint placarCasa = idPartida[_idPartida].placarCasa;
        uint placarVisitante = idPartida[_idPartida].placarVisitante;
        //usamos a library para devolver o valor máximo dos placares
        uint vencedor = placarCasa.max(placarVisitante); //repare na library que retorna uma uint

        //aprendendo a usar o if e else:
        if(vencedor == idPartida[_idPartida].placarCasa){ 
            //se o placar do vencedor for igual ao da Casa
           bool Casavenceu = idPartida[_idPartida].vencedorCasa = true;
           string memory nomeCasa = idPartida[_idPartida].timeCasa;
           //atualiza o mapping do time da casa e soma uma vitória
           VitoriasCasa[nomeCasa]++;
           return (vencedor, (idPartida[_idPartida].timeCasa), (Casavenceu));
        } else {
            //se não for, quer dizer que o time vizitante venceu
            bool Visitantevenceu = idPartida[_idPartida].vencedorVisitante = true;
            string memory nomeVisitante = idPartida[_idPartida].timeVisitante;
            //atualiza o mapping do time visitante e soma uma vitória
           VitoriasVisitantes[nomeVisitante]++;
            return (vencedor,(idPartida[_idPartida].timeCasa), (Visitantevenceu));
        }
        
    }

    function consultarPlacar(uint _idPartida) public view returns (uint256, uint256) {
        return (idPartida[_idPartida].placarCasa, 
        (idPartida[_idPartida].placarVisitante));
    }

    modifier OnlyArbitro(){
        require(msg.sender == Arbitro, "Somente o Arbitro que pode executar");
        _;
    }
}