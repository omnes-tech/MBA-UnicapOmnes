# <h1 align="center"> Hardhat x Foundry Template - Afonso Dalvi</h1>

**Template repository for getting started quickly with Hardhat and Foundry in one project - Deploy and verify whith truffle**

![Github Actions]()

### Getting Started

- Use Foundry na pasta foundry-tamplate: (Os testes no foundry são mais rápidos)

```bash
forge install

forge build
```

- Install libraries with Foundry which work with Hardhat.

```bash
forge install rari-capital/solmate # Already in this repo, just an example
```

```bash
forge test

forge test -vv
```

- Caso esteja usando uma máquina virtual Linux ou um Mac conseguirá executar os comandos abaixo sem problemas:

```bash
avil   (blockchain do foundry)
```

- Para o deploy e verificação dos contratos no foundry deve configurar o env. e executar os comandos na ordem:

```bash
source .env
```

```bash
forge script script/NFT.s.sol:MyScript --rpc-url $RINKEBY_RPC_URL  --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_KEY -vvvv
```

- Use Hardhat na pasta principal template-deploy (melhor opção de deploy e verificação caso esteja usando o Windows):

```bash
yarn
yarn test
```

- Use compile watch or test watch:

```bash
yarn hardhat compile:watch
yarn hardhat test:watch
```

```bash
truffle dashboard  (para não precisar configurar as chaves privadas no seu .env)
```

- Deploy your smart-contract using testnet Truffle Dashboard:

```bash
yarn deploy --network truffle
```

### Features

- Write / run tests with either Hardhat or Foundry:

```bash
forge test
# or
yarn test
```

- Use Truffle Dashboard:

```bash
truffle dashboard
```

- Use Truffle ppara deployar e verificar seus contratos sem necessidade de inserir suas chaves privadas:
  (obs. o truffle dashboard precisa estar executado)

```bash
yarn deploy:truffle
```

```bash
yarn hardhat verify --network truffle 0xCF00fd269fE5Ad09E0907b96AfeeD7e04F8423C6 argumentos

```

- Use Prettier

```bash
yarn prettier
```

### Notes

Fiz um conjunto de implementações para ficar mais fácil o uso de diversos frameworks necessários para iniciar qualquer projeto.
