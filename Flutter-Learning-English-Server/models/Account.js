const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const AccountSchema = new Schema({
    username: { type: String },
    fullName: { type: String, require: true },
    email: { type: String, unique: true },
    password: { type: String },
    role: {
        type: String,
        require: true,
        enum: ["admin", "user"],
    },
    avatar_url: {
        type: String,
        default:
            "https://firebasestorage.googleapis.com/v0/b/phone-c4bc5.appspot.com/o/default_avatar.jpg?alt=media&token=0ff85744-9209-457b-aaf8-66d1f6893155",
    },
});

module.exports = mongoose.model("Account", AccountSchema);
