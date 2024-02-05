const express = require("express");
const app = express();
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const cors = require("cors");

dotenv.config();

const DB_USER =process.env.DB_USER
const DB_PASSWORD=process.env.DB_PASSWORD
const DB_HOST= process.env.DB_HOST
const DB_PORT=process.env.DB_PORT
const DB_NAME=process.env.DB_NAME

const MONGO_URI = `mongodb://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?directConnection=true&authSource=admin&retryWrites=true`

// Connect DB
mongoose
  .connect(MONGO_URI,{ useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log("mongoDB is connected"))
  .catch((err) => console.log(err));

// Middleware
app.use(express.json());
app.use(cors());

// Route
app.use("/user", require("./routes/user"));

app.listen(5000, () => console.log("Server is running on port 5000"));
