import { ethers } from "hardhat";

async function main() {
  const IPFS = "https://bafkreig2xnzfhpgdqgz4tnsgzdx2y6svimng3a7h76mr2dnxs7ieihuwqy.ipfs.nftstorage.link";
  const nome = "Omnes Octopus";
  const symbol = "OMNESCTO";

  const NFT = await ethers.getContractFactory("NFT");
  const nft = await NFT.deploy(nome, symbol, IPFS);

  await nft.deployed();

  console.log("NFT deployed to:", nft.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
