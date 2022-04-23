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
});
const Team = mongoose.model("team", teamSchema);

module.exports = Team;
