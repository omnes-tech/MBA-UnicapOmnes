import { ethers } from "hardhat";

async function main() {

  //deploy do token
  const TOKEN = await ethers.getContractFactory("MBAUnicap");
  const token = await TOKEN.deploy();

  await token.deployed();

  //deploy do DeFi
  const DEFI = await ethers.getContractFactory("DeFiInvestimentoMBA");
  const defi = await DEFI.deploy(token.address);

  await defi.deployed();

  console.log("Token deployed to:", token.address, "DeFi deployed to:", defi.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});