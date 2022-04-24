const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const eventSchema = new Schema({
  name: String,
  description: String,

  teams: [String], // id of the team docuemnts
});
const Event = mongoose.model("User", eventSchema);

module.exports = Event;
