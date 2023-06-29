// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.9.0;

contract sentencia_if{

    uint private numero;

    constructor(uint _numero){
        numero =_numero;
    }
    
    //Numero ganhador
    function provarSorte(uint _numero) public view returns(bool){
        
        bool ganhador;
        if(_numero == numero){//se for o numero igual a inserido na construção ele será o ganhador
            ganhador=true;
        }else{
            ganhador = false;
        }
        
        return ganhador;
        
    }

    //Votacao
    //Temos somente tres candidatos: Joao, Gabriela y Maria
    
    function votar(string memory _candidato) public pure returns(string memory){
        
        string memory mensaje;
        
        if(keccak256(abi.encodePacked(_candidato))==keccak256(abi.encodePacked("Joao"))){
            mensaje = "Quem votou correctamente foi o Joao";
        }else{
            if(keccak256(abi.encodePacked(_candidato))==keccak256(abi.encodePacked("Gabriela"))){
                mensaje = "Quem votou correctamente foi a Gabriel";
            }else{
                if(keccak256(abi.encodePacked(_candidato))==keccak256(abi.encodePacked("Maria"))){
                    mensaje = "Quem votou correctamente foi a Maria";
                }else{
                    mensaje = "Quem votou nao esta na lista";
                }
            }
        }
        
        return mensaje;
    }


 }

