const { ethers } = require("hardhat");

//file for deploying to testnet for testing
async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    //const ENS721Mapper = await ethers.getContractFactory("ENS721Mapper");
    //const ens721mapper = await ENS721Mapper.deploy();



    const TwistedTweaks = await ethers.getContractFactory("TwistedTweaks");
    const twistedtweaks = await TwistedTweaks.deploy("QmdDagL8zjPz5juomhrVGfxNw7aD4jhnTchCSvszcWPmsQ");
  
    //console.log("ENS address:", ens721mapper.address);
    console.log("Tweaks address:", twistedtweaks.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });

    //Tweaks address: 0x77F933a8bede98430Ccf3CC6df9bd7799d2E5963
    //ENS address: 0x7Cbe9e6F12cFb28032E448D155d09a79D3dAE472