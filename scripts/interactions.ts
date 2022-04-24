import { ethers } from "hardhat";
import "hardhat-ethernal";
import hre from "hardhat";

async function main() {
  
  // [ Profile Contract ]
  // setting up the contract by linking it to the one we deployed
  const profileContract = await ethers.getContract("Profile");

  // transaction to mint profile
  let mintTx = await profileContract.mintProfile([
    "", // name
    "", // description
    "", // uri
  ]);
  console.log(mintTx);
  let mintReceipt = await mintTx.wait();
  console.log(mintReceipt);

  // transaction to change/set name
  let setNametx = await profileContract.setName("");
  console.log(setNametx);
  let setNameReceipt = await setNametx.wait();
  console.log(setNameReceipt);

  // transaction to change/set description
  let setDescriptionTx = await profileContract.setDescription("");
  console.log(setDescriptionTx);
  let setDescriptionReceipt = await setDescriptionTx.wait();
  console.log(setDescriptionReceipt);

  // transaction to change/set uri
  let setUriTx = await profileContract.setDescription("");
  console.log(setUriTx);
  let setUriReceipt = await setUriTx.wait();
  console.log(setUriReceipt);

  // transaction to getUserDetails onchain
  let getDetailsTx = await profileContract.getUserDetails("");
  console.log(getDetailsTx);
  let getDetailsReceipt = await getDetailsTx.wait();
  console.log(getDetailsReceipt);

  // [ Equipment/Event Contract ]
  // setting up the contract by linking it to the one we deployed
  const equipmentContract = await ethers.getContract("Equipment");

  // transaction to create a new party
  let createPartyTx = await equipmentContract.createParty(
    0, // initial supply
    "" // uri
  );
  console.log(createPartyTx);
  let createPartyReceipt = await createPartyTx.wait();
  console.log(createPartyReceipt);

  // transaction to join a party
  let joinPartyTx = await equipmentContract.joinParty(0);
  console.log(joinPartyTx);
  let joinPartyReceipt = await joinPartyTx.wait();
  console.log(joinPartyReceipt);

  // transaction to leave a party
  let leavePartyTx = await equipmentContract.joinParty(0);
  console.log(leavePartyTx);
  let leavePartyReceipt = await leavePartyTx.wait();
  console.log(leavePartyReceipt);

  // transaction to set uri
  let setEquipmentUriTx = await equipmentContract.setUri("");
  console.log(setEquipmentUriTx);
  let setEquipmentUriReceipt = await setEquipmentUriTx.wait();
  console.log(setEquipmentUriReceipt);

  // transaction to distribute NFTs
  let distrbuteToAddrTx = await equipmentContract.mintToAddresses([]);
  console.log(distrbuteToAddrTx);
  let distrbuteToAddrReceipt = await distrbuteToAddrTx.wait();
  console.log(distrbuteToAddrReceipt);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
