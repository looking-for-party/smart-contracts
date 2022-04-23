import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ethers } from "hardhat";

const main = async function () {
	// We get the contract to deploy
  const Profile = await ethers.getContractFactory("Profile");
  const profile = await Profile.deploy();

  await profile.deployed();
  console.log("Profile deployed to:", profile.address);

	// We get the contract to deploy
  const Equipment = await ethers.getContractFactory("Equipment");
  const equipment = await Equipment.deploy("");

  await equipment.deployed();

  console.log("Equipment deployed to:", equipment.address);
};

main();
