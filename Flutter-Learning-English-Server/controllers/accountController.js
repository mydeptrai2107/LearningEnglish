const package = require("../middlewares/package.js");
const Account = require("../models/Account.js");
const bcypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const mailer = require("../utils/mailer");

module.exports = {
    login: async (req, res) => {
        try {
            const { email, password } = req.body;

            if (!email || email.length < 1) {
                return res.json(package(1, "Please provide your email!", null));
            } else if (!password || password.length < 1) {
                return res.json(
                    package(1, "Please provide your password!", null)
                );
            }

            //check email ton tai
            const userDB = await Account.findOne({ email: email });
            if (!userDB) {
                return res.json(package(1, "Invalid email or password", null));
            }

            if (bcypt.compareSync(password, userDB.password)) {
                const userWithoutPassword = { ...userDB };
                delete userWithoutPassword._doc.password;

                let prepairUser = { ...userWithoutPassword };
                prepairUser._doc.token = jwt.sign(
                    prepairUser._doc,
                    process.env.JWT_SECRET,
                    { expiresIn: "24h" }
                );
                return res.json(package(0, "Login success", prepairUser._doc));
            }
            return res.json(package(1, "Invalid username or password", null));
        } catch (error) {
            return res.json(package(2, "Internal error", error.message));
        }
    },

    register: async (req, res) => {
        try {
            const { username, fullName, email, password, imageUrl } = req.body;

            const checkEmailExist = await Account.find({ email: email });
            if (checkEmailExist.length > 0)
                return res.json(package(1, "Email is exist ", null));

            // const checkUsernameExist = await Account.find({
            //     username: username,
            // });
            // if (checkUsernameExist.length > 0)
            //     return res.json(package(1, "Usename is exist", null));

            const hashedPassword = bcypt.hashSync(password, 10);

            const newAccount = new Account({
                username: username,
                fullName: fullName,
                email: email,
                role: "user",
                password: hashedPassword,
                avatar_url: imageUrl,
            });

            const result = await newAccount.save();
            if (!result) return res.json(package(1, "Can not save user", null));

            const mailResult = await mailer.sendMail(
                email,
                "Quiz Card - Your accout has been created",
                accountCreateAccount(fullName)
            );
            if (mailResult.status === "error")
                return res.json(
                    package(1, "Internal error", mailResult.message)
                );
            return res.json(package(0, "Save user successfully", result));
        } catch (error) {
            res.json(package(2, "Internal error", error.message));
        }
    },

    getProfile: async (req, res) => {
        try {
            const _id = req.params.uid;
            const result = await Account.findById(_id);
            if (result)
                return res.json(package(0, "Get user successfully", result));
            return res.json(package(1, "Can not get user", null));
        } catch (error) {
            res.json(package(2, "Internal error", error.message));
        }
    },

    resendVerifyEmail: async (req, res) => {
        try {
            const { email } = req.body;

            const user = await Account.findOne({ email: email });
            if (!user) return res.json(package(1, "Can not find user", null));

            // Tạo mật khẩu mới
            const password = generatePassword();
            const hashedPassword = bcypt.hashSync(password, 10);

            // Cập nhật mật khẩu người dùng
            user.password = hashedPassword;
            await user.save();

            // Gửi email thông báo
            const mailResult = await mailer.sendMail(
                email,
                "Reset your password",
                annouceChangAccount(user.fullName, password)
            );
            if (mailResult.status === "error")
                return res.json(
                    package(1, "Internal error", mailResult.message)
                );

            return res.json(package(0, "Send email successfully", null));
        } catch (error) {
            return res.json(package(2, "Internal error", error.message));
        }
    },

    changePassword: async (req, res) => {
        try {
            const { _id, oldPassword, newPassword } = req.body;

            const user = await Account.findById(_id);
            if (!user) return res.json(package(1, "Internal error", null));

            if (!bcypt.compareSync(oldPassword, user.password))
                return res.json(package(1, "Password not match"));
            const hashedPassword = bcypt.hashSync(newPassword, 10);
            user.password = hashedPassword;
            await user.save();
            res.json(package(0, "Change password successfully!", null));
        } catch (error) {
            return res.json(package(2, "Internal error", error.message));
        }
    },
};

function generatePassword() {
    const characters =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    let password = "";
    for (let i = 0; i < 5; i++) {
        const randomIndex = Math.floor(Math.random() * characters.length);
        password += characters[randomIndex];
    }
    return password;
}

function accountCreateAccount(name) {
    return `
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: Arial, sans-serif;
                    background-color: #f4f4f4;
                    margin: 0;
                    padding: 0;
                }
                .container {
                    width: 100%;
                    max-width: 600px;
                    margin: 0 auto;
                    background-color: #ffffff;
                    border: 1px solid #dddddd;
                    padding: 20px;
                }
                .header {
                    background-color: #4CAF50;
                    color: #ffffff;
                    padding: 10px 0;
                    text-align: center;
                }
                .header h1 {
                    margin: 0;
                    font-size: 24px;
                }
                .content {
                    padding: 20px;
                    text-align: center;
                }
                .content h2 {
                    color: #333333;
                }
                .content p {
                    color: #666666;
                    font-size: 16px;
                    line-height: 1.5;
                }
                .content a {
                    display: inline-block;
                    margin-top: 20px;
                    padding: 10px 20px;
                    background-color: #4CAF50;
                    color: #ffffff;
                    text-decoration: none;
                    border-radius: 5px;
                }
                .footer {
                    text-align: center;
                    padding: 10px 0;
                    font-size: 12px;
                    color: #999999;
                    border-top: 1px solid #dddddd;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Congratulations!</h1>
                </div>
                <div class="content">
                    <h2>Account Successfully Created</h2>
                    <p>Hello ${name},</p>
                    <p>
                        Your account has been successfully created. Thank you for registering at our website. 
                        You can now log in and start using our services.
                    </p>
                </div>
                <div class="footer">
                    <p>If you did not create this account, please disregard this email.</p>
                    <p>&copy; 2024 Group 49. All rights reserved.</p>
                </div>
            </div>
        </body>
        </html>

    `;
}

function annouceChangAccount(userName, newPassword) {
    return `
    <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Reset Notification</title>
    <style>
        body {
            font-family: Arial, sans-serif;
        }
        .container {
            width: 100%;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            border: 1px solid #cccccc;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        .header {
            text-align: center;
            padding-bottom: 20px;
        }
        .content {
            padding: 20px 0;
        }
        .footer {
            text-align: center;
            padding-top: 20px;
            color: #777777;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>Password Reset Notification</h2>
        </div>
        <div class="content">
            <p>Dear ${userName},</p>
            <p>Your password has been successfully reset. Here are your new login details:</p>
            <p><strong>New Password:</strong> ${newPassword}</p>
            <p>Please make sure to change your password after your next login to ensure your account's security.</p>
            <p>If you did not request this change, please contact our support team immediately.</p>
            <p>Best regards,</p>
            <p>Group 49</p>
        </div>
        <div class="footer">
            <p>&copy; 2024 Group 49. All rights reserved.</p>
        </div>
    </div>
</body>
</html> 
    `;
}
