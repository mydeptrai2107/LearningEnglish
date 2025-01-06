const express = require("express");
const router = express.Router();
const {
    register,
    login,
    getProfile,
    resendVerifyEmail,
    changePassword,
} = require("../controllers/accountController");

//[post] /register
router.post("/register", register);

//[post] /login
router.post("/login", login);

//[get] /:uid
router.get("/:uid", getProfile);

//[get] /resetPassword
router.post("/reset", resendVerifyEmail);

//[post]
router.post("/changePassword", changePassword);

module.exports = router;
