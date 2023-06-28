// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


//contrato que aceita noosso token
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ERC20.sol";
import "./libraryMath.sol";

//REMIX USAR AS IMPORTAÇÕES ABAIXO:
//import "https://github.com/Afonsodalvi/solmate/blob/main/src/tokens/ERC20.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.2/contracts/token/ERC20/IERC20.sol";

contract DeFiInvestimentoMBA is ERC20{

    address dono;
    using Math for uint;

    IERC20 public tokenMBA;

    struct Regras{
        uint256 prazo;
        uint recompensaPortempo;
        bool banido;
        uint quantidadeInvest;
        bool retirarLucro;
    }
mapping(address => Regras) public regras;

constructor(address _token) ERC20("DeFiMBA","DFiMBA",18){
 tokenMBA = IERC20(_token);
 dono = msg.sender;
}

function investirTokens(uint _quantidade)external {
    
    tokenMBA.transferFrom(msg.sender,address(this), _quantidade);
    regras[msg.sender] = Regras({
        prazo: block.timestamp,
        recompensaPortempo: 10,
        banido: false,
        quantidadeInvest: _quantidade,
        retirarLucro: false
    });
}


function claim() external{
    require(!regras[msg.sender].retirarLucro, "ja retirou o lucro!");
    require(regras[msg.sender].quantidadeInvest >= 10, 
    "Investiu menos que 10 tokens, ta de sacanagem?");
    if( (block.timestamp) - (regras[msg.sender].prazo) > 30 seconds){
        bool podeRetirar = regras[msg.sender].retirarLucro = true;
        uint valorInvestido = regras[msg.sender].quantidadeInvest;
        uint valorRecompensa = regras[msg.sender].recompensaPortempo;
        uint recompensaTotal;
        (podeRetirar, recompensaTotal) = Math.tryMul(valorInvestido,valorRecompensa);
        _mint(msg.sender, recompensaTotal);
    }else{
        _mint(msg.sender, 1);
    }

}

 }