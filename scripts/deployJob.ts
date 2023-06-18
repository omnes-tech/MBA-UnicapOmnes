import { ethers } from "hardhat";

async function main() {
  const IPFS = "https://bafkreia3mz2vnxe4xzmzyclnooazeuoasn2eghx7krc5qqnzknukxcgzwe.ipfs.nftstorage.link";
  const nome = "OmnesMentoring";
  const symbol = "OMNESM";
//"https://ipfs.io/ipfs/CID.json"
  const NFT = await ethers.getContractFactory("Job");
  const nft = await NFT.deploy(IPFS,0,0, nome, symbol);

  await nft.deployed();

  console.log("Job deploy:", nft.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});