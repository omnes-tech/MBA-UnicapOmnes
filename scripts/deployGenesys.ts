import { ethers } from "hardhat";

async function main() {

 // const QualquerMrkle = "81cd02ab7e569e8bcd9317e2fe99f2de44d49ab2b8851ba4a308000000000000";
  const baseURI = "https://bafybeic6pb52otefewwrowbjzmg2n7tsivjkydwx46pimvhkb32a4yqpnq.ipfs.nftstorage.link/"
  const Base2 = "https://bafybeic6pb52otefewwrowbjzmg2n7tsivjkydwx46pimvhkb32a4yqpnq.ipfs.nftstorage.link/";
  const hiddenmessage = "Olá MUNDO";
  
  //deploy do token
  const TOKEN = await ethers.getContractFactory("GenesisDAO");
  const token = await TOKEN.deploy(baseURI, Base2, hiddenmessage);

  await token.deployed();


  console.log("Genesis deployed to:", token.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});