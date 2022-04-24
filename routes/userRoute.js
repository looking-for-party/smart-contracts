const express = require("express");
const router = express.Router();
const User = require("../models/userModels");
const ipfsAPI = require("ipfs-api");
const fs = require("fs");
const { v4: uuidv4 } = require("uuid");
const path = require("path");

router.post("/", async (req, res) => {
  try {
    const { ethereumAddress, firstName, lastName } = req.body;

    if (!ethereumAddress)
      res.status(400).send({ message: "Invalid ethereum address" });
    const userId = uuidv4();
    const userDetails = { userId, ethereumAddress };
    if (firstName) userDetails.firstName = firstName;
    if (lastName) userDetails.lastName = lastName;

    const newUser = new User(userDetails);
    await newUser.save();
    const ipfs = ipfsAPI("ipfs.infura.io", "5001", { protocol: "https" });
    const userNFTFile = fs.readFileSync(path.join(__dirname, "test.txt"));
    const fileBuffer = Buffer.from(userNFTFile);
    ipfs.files.add(fileBuffer, function (err, file) {
      if (err) {
        res.status(500).send(err?.message || err);
      }

      // Todo connect to the ourOwn local host if necessary
      console.log(file);
      res.status(200).send({
        userId,
        message: "User created",
        fileHash: file[0].hash,
        firstName,
        lastName,
      });
    });
  } catch (e) {
    console.log("Error : ", e);
    res.status(500).send(e?.message);
  }
});

router.patch("/", async (req, res) => {
  try {
    const { userId, profileNFTTokenId } = req.body;
    if (!userId) return res.status(400).send("Invalid userId");
    if (!profileNFTTokenId)
      return res.status(400).send("Invalid profileNFTTokenId");
    console.log({ profileNFTTokenId });
    await User.updateOne(
      { userId },
      { $set: { profileNFTTokenId: +profileNFTTokenId } }
    );
    return res.status(200).send({ message: "Updated User" });
  } catch (e) {
    console.log("Error : ", e);
    return res.status(500).send(e?.message || e);
  }
});
router.get("/all", async (req, res) => {
  const users = await User.find({});
  return res.status(200).send(users);
});

router.get("/all", async (req, res) => {
  const users = await User.find({});
  return res.status(200).send(users);
});

router.get("/eth/:ethereumAddress", async (req, res) => {
  try {
    const { ethereumAddress } = req.params;
    if (!ethereumAddress)
      return res.status(400).send("Invalid ethereumAddress");
    const user = await User.findOne({ ethereumAddress });
    if (!user) return res.status(400).send("Invalid userId");
    return res.status(200).send({
      userId: user.userId,
      firstName: user.firstName,
      lastName: user.lastName,
      ethereumAddress: user.ethereumAddress,
      created: user.created,
    });
  } catch (e) {
    console.log("Error : ", e);
  }
});
router.get("/:userId", async (req, res) => {
  try {
    const { userId } = req.body;
    if (!userId) return res.status(400).send("Invalid userId");
    const user = await User.findOne({ userId: req.params.userId });
    if (!user) return res.status(400).send("Invalid userId");
    delete user._id;
    return res.status(200).send({
      userId: user.userId,
      firstName: user.firstName,
      lastName: user.lastName,
      ethereumAddress: user.ethereumAddress,
      created: user.created,
    });
  } catch (e) {
    console.log("Error : ", e);
    return res.status(500).send(e?.message || e);
  }
});
module.exports = router;
