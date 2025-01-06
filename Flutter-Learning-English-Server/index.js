const express = require("express");
const mongoose = require("mongoose");
const path = require("path");
require("dotenv").config();
const cors = require('cors');

const app = express();

app.use(cors());

app.set("view engine", "ejs");
app.use("/", express.static(path.join(__dirname, "public")));

const bodyParser = require("body-parser");
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.get("/", (req, res) => {
    res.json({ code: 0, message: "Server launched successfully" });
});

app.use("/accounts", require("./routers/Account"));

app.use("/folders", require("./routers/Folder"));

app.use("/topics", require("./routers/Topic"));

app.use("/achievements", require("./routers/Achievement"));

app.use((req, res) => {
    res.json({ code: 2, message: "Path is not supported" });
});

const PORT = process.env.PORT || 3000;
const LINK = "http://localhost:" + PORT;
const { MONGODB_URI, DB_NAME } = process.env;
mongoose
    .connect(MONGODB_URI, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        dbName: DB_NAME,
    })
    .then(() => {
        app.listen(PORT, () => {
            console.log(LINK);
        });
    })
    .catch((e) => console.log("Can not connect db server: " + e.message));
