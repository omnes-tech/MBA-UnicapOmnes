// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


contract ExemplosArrays{

    uint256[] public Dinamic;
    string[4] public Alunos;
    string[] public DisciplinaNome;
    string[][] public NotasArray; //começa no zero a nota

    //inserir indice na array...
    function definirElemento(uint256 indice) external {
        Dinamic.push(indice);
    }
    //inserir nome da disciplina...
    function definirDisciplina(string memory nomeD) external{
        DisciplinaNome.push(nomeD);
    }

    //Excluir nome da disciplina...
    function deletarElemento(uint numeroD) external {
        delete DisciplinaNome[numeroD];
    }

    //Definir nome de aluno e por número...
    function definirAluno(uint8 num, string memory novoAluno) external{
        Alunos[num]=novoAluno;
    }

    //Definir Nota da disciplina onde 
    function definirNotaDisciplina(string memory disciplina, string memory professor)external {
        NotasArray.push([disciplina,professor]);  
    }

    //Definir Nota da disciplina onde 
    function RetornarNotaDisciplina(uint Indicedisciplina, uint IndiceProf)external view returns(string memory){
        return NotasArray[Indicedisciplina][IndiceProf];
    }

}