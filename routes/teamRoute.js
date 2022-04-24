/* eslint-disable node/no-path-concat */
const express = require("express");
const router = express.Router();
const User = require("../models/userModels");
const Team = require("../models/teamModel");
const { v4: uuidv4 } = require("uuid");
const ipfsAPI = require("ipfs-api");
const fs = require("fs");
const path = require("path");

// const multer = require("multer");

// const storage = multer.diskStorage({
//   destination: (req, file, cb) => {
//     cb(null, "uploads/");
//   },
//   filename: (req, file, cb) => {
//     let parts = file.originalname.split(".");
//     const ext = parts.pop();
//     const name = parts.join(".");
//     parts = name.split(" ").join(".");
//     cb(null, +Date.now() + "." + ext);
//   },
// });

// const upload = multer({ storage: storage });

const addFileToIPFS = (fileBuffer) => {
  return new Promise((resolve, reject) => {
    const ipfs = ipfsAPI("ipfs.infura.io", "5001", { protocol: "https" });
    ipfs.files.add(fileBuffer, function (err, file) {
      if (err) return reject(err?.message || err);

      // Todo connect to the ourOwn local host if necessary
      return resolve(file[0].hash);
    });
  });
};

router.post("/", async (req, res) => {
  try {
    const { name, description, totalNumberOfPeople, adminUserId, url, icon } =
      req.body;
    if (!name) return res.status(400).send("Invalid name");
    if (!description) return res.status(400).send("Invalid description");
    if (!totalNumberOfPeople)
      return res.status(400).send("Invalid totalNumberOfPeople");
    if (!adminUserId) return res.status(400).send("Invalid adminUserId");
    const user = await User.findOne({ userId: adminUserId });
    if (!user) return res.status(400).send("Invalid adminUserId");
    const base64Data = icon.replace(/^data:image\/png;base64,/, "");
    const date = Date.now();
    const fileName = `${__dirname}/../uploads/${date}.png`;
    fs.writeFileSync(fileName, base64Data, "base64", function (err) {
      console.log(err);
    });
    const teamId = uuidv4();

    const userNFTFile = fs.readFileSync(path.join(__dirname, "hat.jpg"));
    const fileBuffer = Buffer.from(userNFTFile);
    const teamNFTHash = await addFileToIPFS(fileBuffer);
    const teamDetails = {
      teamId,
      name,
      description,
      adminUserId,
      participants: [adminUserId],
      teamNFTHash,
      iconPath: fileName,
      url,
    };
    const newTeam = new Team(teamDetails);
    await newTeam.save();
    return res
      .status(200)
      .send({ teamId, message: "Team created", teamNFTHash, icon: date });
  } catch (e) {
    console.log("Error : ", e);
    res.status(500).send(e?.message || e);
  }
});

router.patch("/", async (req, res) => {
  try {
    const { userId, teamId } = req.body;
    const user = await User.findOne({ userId });
    const team = await Team.findOne({ teamId });
    if (!user || !team) res.status(400).send("Invalid userId or teamIs");
    if (+team.totalNumberOfPeople >= team.participants.length)
      return res.status(400).send("Can not add more participants!");
    await Team.updateOne({ teamId }, { $push: { participants: userId } });
    return res.status(200).send({ message: "Team updated!" });
  } catch (e) {
    console.log("Error : ", e);
    res.status(500).send(e?.message || e);
  }
});

router.get("/all", async (req, res) => {
  try {
    const team = await Team.find({});
    return res.status(200).send(team);
  } catch (e) {
    console.log("Error : ", e);
    res.status(500).send(e?.message || e);
  }
});

router.get("/:teamId", async (req, res) => {
  try {
    const { teamId } = req.body;
    if (!teamId) return res.status(400).send("Invalid teamId");
    const team = await Team.findOne({ teamId });
    res.status(200).send(team);
  } catch (e) {
    console.log("Error : ", e);
    return res.status(500).send(e?.message || e);
  }
});

router.get("/addresses/:teamId", async (req, res) => {
  try {
    const { teamId } = req.params;
    if (!teamId) res.status(400).send("Invalid teamId");
    const team = await Team.findOne({ teamId });
    if (!team) res.status(400).send("Invalid teamId");
    console.log({ team });
    const usersIds = team.participants;
    console.log({ usersIds });
    const contractIds = [];

    for (let userCount = 0; userCount < usersIds.length; userCount++) {
      const userDetails = await User.findOne(
        { userId: usersIds[userCount] },
        { ethereumAddress: 1 }
      );
      contractIds.push(userDetails.ethereumAddress);
    }
    return res.status(200).send({ teamId, contractIds });
  } catch (e) {
    console.log("Error : ", e);
    return res.status(500).send(e?.message || e);
  }
});

// router.post("/remove-member", (req, res) => {

// });

// router.post("/update-nft-assignment", (req, res) => {
//   const {} = req.body;
// });

module.exports = router;
