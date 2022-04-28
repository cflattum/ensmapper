const { ethers } = require("hardhat");

//file for deploying to testnet for testing
async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const ENS721Mapper = await ethers.getContractFactory("ENS721Mapper");
    const ens721mapper = await ENS721Mapper.deploy();

    const TwistedTweaks = await ethers.getContractFactory("TwistedTweaks");
    const twistedtweaks = await TwistedTweaks.deploy();
  
    console.log("ENS address:", ens721mapper.address);
    console.log("Tweaks address:", ens721mapper.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });