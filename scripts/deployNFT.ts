import { ethers } from "hardhat";

async function main() {
  
    const IPFS = "https://ipfs.io/ipfs/CID.json";
    const nome = "Afonso";
    const symbol ="henrique"


  const NFT = await ethers.getContractFactory("NFT");
  const nft = await NFT.deploy(nome, symbol, IPFS);

  await nft.deployed();

  console.log("Lock with 1 ETH deployed to:", nft.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
