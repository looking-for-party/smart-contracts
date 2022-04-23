const dotenv = require("dotenv");
dotenv.config({ path: "../.env" });
const User = require("../models/userModels");
const Team = require("../models/teamModel");
const mongoose = require("mongoose");

const connectMongo = async () => {
  try {
    await mongoose.connect(process.env.MONGO_DEV_URL);
    console.info(
      "Connected to MongoDB..." + process.env.MONGO_DEV_URL.split("@")[1]
    );
  } catch (error) {
    console.error("Error connecting to MongoDB = ", error.message);
  }
};

const clearDb = async () => {
  try {
    await connectMongo();
    await User.remove({});
    await Team.remove({});
  } catch (e) {
    console.log("Error : ", e);
  }
};
clearDb();
