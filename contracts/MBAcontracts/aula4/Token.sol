// SPDX-License-Identifier: GLP-3.0

pragma solidity >=0.5.0 <0.9.0; // 
//---------------------------------------------------------------
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIP/eip-20
//------------------------------------------------------

//implemente de forma facilitada pelo wizard:
//https://wizard.openzeppelin.com/

interface IERC20{
    function totalSupply() external view returns(uint); //numeros de tokens criados, com função externa que não gasta gas e retorna o valor
    function balanceOf(address tokenOwner) external view returns (uint balance); //saldo de tokens, com função externa que não gasta gas e retorna o valor do saldo
    function transfer(address to, uint tokens) external returns (bool success); // transferencia de token, com função externa que retorna booliana verdadeira ou falsa.

// As funções abaixo vamos delimitar uma quantidade de crédito especifico autorizado pelo criador do token, para endereços específicos. Sendo possível o endereço autorizado gastar somente o que foi delimitado pelo criador do token
    function allowance(address tokenOwner, address spender) external view returns(uint remaining);//Permição do criador do token para o endereço que irá gastar o determinado token e a quantidade delimitada 
    function approve(address spender, uint tokens) external returns (bool success);//aprovação do endereço gastador e envio dos tokens, com função externa que retorna booliana verdadeira ou falsa
    function transferFrom(address from, address to, uint tokens) external returns (bool sucess); //treanferencia de um endereço para o outro os valores dos tokens, com função externa e retorna booliana verdadeira ou falsa

    event Transfer(address indexed from, address indexed to, uint tokens); //evento da transferencia do endereço que transferiu e do endereço que recebeu os tokens 
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);//evento da aprovação com o endereço do dono do token o endereço gastador(comprador) e a quiantidade de tokens.

// repare o padrão de de 6 funções e 2 eventos que é aceito universalmente nos ERC20 tokens.
}

contract MBAUnicap is IERC20{ // vamos definir as variáveis estáveis de um ERC20
    string public name = "MBA-Unicap"; //O nome é igual a criptos, cada token ou criptomoeda tem seu próprio símbolo, como BTC para bitcoin ou éter
    string public symbol = "UNICAP"; // simbolo do seu token/cripto
    uint public decimals = 0; //quantidade de decimals. Posteriormente iremos mudar para 18, que é o mais utilizado e aceito.
    uint public override totalSupply; // valor da quantidade de tokens criados, devemos utilizar a função override para conseguirmos falar com o interface ERC20 e sua função totalSupply

//Lembre-se de utilizar os mesmo nomes das funções e variáveis da interface ERC20Interface.

    address public founder;// endereço do fundador do token
    mapping(address=> uint) public balances; //O mapping é relativo aos saldos das carteiras/endereços que receberam os tokens e seus valores, ou seja, guarda a quantidade/saldo de tokens que o endereço possui   
    //por exemplo: balances[0x111...] = 100; o endereço 0x111 possui 100 tokens e esta armazenado essa informação no balances que se trata de um mapping(como se fosse um banco de dados na blockchain)


//Agora vamos implementar as 3 primeiras funções da interface ERC20, as que são de fato usadas no token.
//Para isso, devemos mutar as funções e ventos do ERC20interface que não serão usados, bem como o evento.


//o mapping abaixo e demais funções é na implementação da segunda etapa e que haverá a permição do endereço especifico para gastar uma determinada quantia de tokens, com a autorização do criador dos tokens

//  1.endereços dono token  2.endereços aprovados e quantidade de crédito de tokens que podem ser transferidos
mapping(address => mapping(address=>uint)) allowed; //esse mapeamento inclui contas aprovadas para saques de uma determinada conta junto com o saque, alguns permitidos para cada uma delas.
// As chaves são do tipo endereço e os endereços dos detentores de tokens, os valores correspondentes são outros mapeamentos que representam os endereços que podem ser transferidos do saldo dos detentores e o valor que pode ser transferido.
// exemplo para o entendimento:
//0x111...(owner/dono) allows/autorizou 0x2222...(the spender/a gastar)----- 100 tokens
//ou seja, allowed[0x111...][0x2222...] = 100;
//Exemplificando: O endereço dono dos tokens é a chave para autorizar o endereço que vai gastar os tokens com a quantidade delimitada.
//Entendido, vamos para a função allowance....


//

constructor() {
    totalSupply= 100000000;// o total de tokens criados 
    founder = msg.sender;// o criador será que fez o deploy
    balances[founder] = totalSupply; //o saldo relativo aos tokens criados vai para a conta do criador dos tokens, ou seja, ele que terá os tokens inicialmente e poderá vender ou distribuir.

}

function balanceOf(address tokenOwner) public  view override returns (uint balance){ //lembre-se que quando temos um interface devemos usar na função do contrato o override para conseguir implementa-lo
    return balances[tokenOwner]; //Dessa forma, retorna o saldo de tokens da conta inserida na função
}

function transfer(address to, uint tokens) public override returns (bool success){ //utilizamos a função de tranferir tokens para uma conta determinada nesta função
    require(balances[msg.sender]>= tokens, "voce nao tem tokens suficiente para realizar a transferencia"); //condição de que a conta que esta mandando o token deve ter mais ou igual o numero de tokens que está querendo transferir, caso não tenha não será possível

    balances[to]+=tokens; //ao conferir que a conta que esta transferindo possui os tokens, agora os tokens serão transferidos e somados na conta do endereço que foi enviado
    balances[msg.sender]-=tokens;// e portanto, diminuido o numero de tokens da conta que fez a transferencia
    emit Transfer(msg.sender, to, tokens); //emitindo o endereço de quem tranferiu o de que recebeu os tokens e a quantidade de tokens

    return true; //assim que passar a condição e for feito as tranferencias irá retorna como verdadeira a transferencia, ou seja, o sucesso.
}

function allowance(address tokenOwner, address spender) view public override returns(uint){//função de autorização do dono dos tokens para o endereço que poderá gastar a quantidade de tokens delimitada
    return allowed[tokenOwner][spender]; //retorna os endereços do mapping allowed e endereços inseridos.
}

function approve(address spender, uint tokens) public override returns (bool success){ //função de aprovar a autorização de crédito dos tokens para o gastador
    require(balances[msg.sender] >=tokens, "Voce nao tem o numero suficiente de tokens para autorizar ao spender"); //condição de quem for aprovar tem que ter o saldo em sua carteira de tokens igual ou maior ao inserido na função
    require(tokens > 0);


    //agora vamos atualizar o mapping allowed que são as contas autorizadas a gastarem determinado numero de tokens.
    allowed[msg.sender][spender] = tokens; //a conta que aprova é a conta que executa essa função e também aprova ao gastador(spnder) a quantidade delimitada de tokens, ou seja, a autorização é do dono dos tokens para o gastador será igual ao numero de tokens autorizados.

    emit Approval(msg.sender, spender, tokens); //emite o endereço do dono dos tokens que executou a função de aprovar o endereço do sender(gastador) e a quantidade de tokens aprovados.
    return true; // concluido as delimitações acima retorna verdadeiro e sucesso na aprovação.
}

 function transferFrom(address from, address to, uint tokens) public override returns (bool success){
     require(allowed[from][to]>= tokens, "A quantidade de tokens autorizados da conta from para a to deve ser maior que a quantidade de tokens aqui inserido, ou seja, insira somente um numero menor de tokens que a delimitada na autorizacao");//condição de que a autorização do endereço que vai autorizar(from) para o endereço que esta sendo autorizado(to), tenha um numero de tokens igual ou maior que o autorizado por este (from)
     require(balances[from]>= tokens, "o saldo da conta from deve ser maior ou igual a qauntidade de tokens aqui inseridos");// o saldo do endereço que está fazendo a transferencia tem que ter um numero de tokens igual ou maior que o inserido por ele.

    balances[from] -= tokens; //dessa maneira se atualiza a quantidade de tokens na conta que vai fazer a transferencia para a conta que de quem ele enviou os tokens.
    balances[to] += tokens; //atualiza a quantidade de tokens no endereço que foi enviado os mesmos, ou seja, soma a quantidade de tokens transferida para a conta do endereço "to"
    allowed[from][to] -= tokens; //atualiza a quantidade de tokens autorizados entre o endereço que autorizou(from) e o endereço que está sendo autorizado(to), ou seja, se o endereço A havia autorizado para B 100 tokens e houve a transferencia de 50 tokens, restaram somente mais 50 tokens.
    return true; //feito isso, a transferencia será realizada com sucesso.
 }

 function mint(uint _quantity) public { //função que permite qualquer um mintar
    totalSupply += _quantity;
    balances[msg.sender] += _quantity;
 } //sempre devemos atualizar todas as informações

}