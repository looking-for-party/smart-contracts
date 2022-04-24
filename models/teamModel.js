const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const teamSchema = new Schema({
  teamId: String,
  name: String,
  description: String,
  participants: [String],
  adminUserId: String,
  totalNumberOfPeople: Number,
  created: { type: Date, default: Date.now },
  totalTeamSize: Number,
  teamNFTHash: String,
  iconPath: String,
  url: String,
  tokenId: Number,
});
const Team = mongoose.model("team", teamSchema);

module.exports = Team;
