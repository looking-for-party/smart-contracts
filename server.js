const express = require("express");
const bodyParser = require("body-parser");
const userRoute = require("./routes/userRoute");
const teamRoute = require("./routes/teamRoute");
// const passport = require("passport");
const cors = require("cors");
const path = require("path");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
dotenv.config();
console.log(process.env.MONGO_DEV_URL);

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

connectMongo();

class Server {
  constructor() {
    this.port = process.env.PORT || 4321;
    this.app = express();
  }

  config() {
    // require("./controllers/auth");
    // this.app.use(passport.initialize());
    // this.app.use(passport.session());
    this.app.use(bodyParser.json());
    this.app.use(cors());
    this.app.use(
      bodyParser.urlencoded({
        extended: false,
      })
    );
    // this.app.use("/uploads", express.static(__dirname + "/uploads"));
    this.app.use("/api/user", userRoute);
    this.app.use("/api/team", teamRoute);
    this.app.use("/uploads", express.static(path.join(__dirname, "/uploads")));

    this.app.use(express.static("client/build"));

    this.app.get("*", function (request, response) {
      const filePath = path.resolve(__dirname, "client", "build", "index.html");
      response.sendFile(filePath);
    });
  }

  start() {
    this.config();
    this.app.listen(this.port, () => {
      console.log(
        "Starting dashboard server..\n listening on port ",
        this.port
      );
    });
  }
}

const app = new Server();
app.start();
