const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const userSchema = new Schema({
  userId: String,
  firstName: String,
  lastName: String,
  ethereumAddress: String,
  profileNFTContractAddress: String,
  created: { type: Date, default: Date.now },
});
const User = mongoose.model("user", userSchema);

module.exports = User;
