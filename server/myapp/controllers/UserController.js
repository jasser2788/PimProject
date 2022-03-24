const UserRepository = require("../repositories/UserRepository");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const jwtConfig = require("../config/jwt");
const hash = require("../utils/hash");
const multer = require("multer");
const path = require("path");
const _ = require("lodash");
const mongoose = require("mongoose");
const User = mongoose.model("User");
const nodemailer = require("nodemailer");
let url = "";
var fs = require("fs");
var handlebars = require("handlebars");
var readHTMLFile = function (path, callback) {
  fs.readFile(path, { encoding: "utf-8" }, function (err, html) {
    if (err) {
      throw err;
      callback(err);
    } else {
      callback(null, html);
    }
  });
};

let transport = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 25,
  auth: {
    user: "eya.yousfi@esprit.tn",
    pass: "181JFT13166",
  },
});

// Multer File upload settings
const DIR = "./public/";

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, DIR);
  },
  filename: (req, file, cb) => {
    const fileName = file.originalname.toLowerCase().split(" ").join("-");
    cb(null, fileName);
  },
});

// Multer Mime Type Validation
var upload = multer({
  storage: storage,
  limits: {
    fileSize: 1024 * 1024 * 5,
  },
  fileFilter: (req, file, cb) => {
    if (
      file.mimetype == "image/png" ||
      file.mimetype == "image/jpg" ||
      file.mimetype == "image/jpeg"
    ) {
      cb(null, true);
    } else {
      cb(null, false);
      return cb(new Error("Only .png, .jpg and .jpeg format allowed!"));
    }
  },
});

function generateJwtToken(user) {
  const { _id } = user;
  return jwt.sign(
    {
      _id,
    },
    jwtConfig.secret
  );
}

class UserController {
  async create(req, res) {
    try {
      const { email, username, password, profilepic } = req.body;
      if (!username || !password || !email) {
        return res.json({
          error: true,
          errorMessage: "Please fill out all fields!.",
        });
      }
      const user = {
        email,
        username,
        password,

        profilepic,
      };
      const userExists =
        (await UserRepository.findByUsername(user.username)) != null;
      if (userExists) {
        return res.json({
          error: true,
          errorMessage: "User Already Exists",
        });
      }
      const userExists2 =
        (await UserRepository.findByEmail(user.email)) != null;
      if (userExists2) {
        return res.json({
          error: true,
          errorMessage: "User Already Exists!",
        });
      }

      await UserRepository.create(user);
      const newUser = await UserRepository.findByUsername(user.username);
      const token = generateJwtToken(newUser);
      user.password = undefined;
      return res.json({
        user: newUser,
        token,
      });
    } catch (err) {
      return res.json({
        error: true,
        errorMessage: "Database Error, Check again.",
        err,
      });
    }
  }

  async login(req, res, next){
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.json({ error: true, errorMessage: "Please enter all fields!" })
        }
        const user = await UserRepository.findByEmail(email);
        if (!user){
            return res.json({ error: true, errorMessage: "Email / password is incorrect!" });
        }
        if (!await bcrypt.compare(password, user.password)){
            return res.json({ error: true, errorMessage: "Email / password is incorrect!" });
        }
        const token = generateJwtToken(user);
        user.password = undefined;
        return res.json({
            user,
            token
        });
    } catch (err){
        return res.json({
            error: true,
            errorMessage: err
        })
    }
}

  async delete(req, res) {
    try {
      const { id } = req.params;
      await UserRepository.delete(id);
      res.json({
        success: true,
      });
    } catch (e) {
      res.json({
        error: true,
        errorMessage: e,
      });
    }
  }

  verifyemail(req, res) {
    try {
      const { email } = req.params;
      const { nb } = req.params;
      readHTMLFile(__dirname + "/emailconfirmation.html", function (err, html) {
        var template = handlebars.compile(html);
        var replacements = {
          code: nb,
        };
        var htmlToSend = template(replacements);
        var mailOptions = {
          from: "Support@learnly.com",
          to: email,
          subject: "EMAIL VERIFICATION",
          html: htmlToSend,
        };
        transport.sendMail(mailOptions, function (error, response) {
          if (error) {
            console.log(error);
            callback(error);
          }
        });
      });
      res.json({
        success: true,
      });
    } catch (err) {
      res.json({
        error: true,
      });
    }
  }

  async modify(req, res) {
    try {
      const { _id, email, username, password } = req.body;
      const userExists = await UserRepository.findUserById(_id);
      if (!userExists) res.json("user does not exist").status(404);
      await UserRepository.update(_id, req.body);
      res.json("user updated successfully").status(200);
    } catch (err) {
      console.log(err);
      res.json({
        error: true,
        errorMessage: "Database Error, Check again.",
      });
    }
  }

  async getUsers(req, res) {
    try {
      const myId = req._id;
      const name = req.query.name;
      if (name) {
        let user = await UserRepository.getUserByName(myId, name);
        const lowerUserId = myId < user._id ? myId : user._id;
        const higherUserId = myId > user._id ? myId : user._id;
        user.chatId = hash(lowerUserId, higherUserId);
        return res.json({
          user,
        });
      }
      let users = await UserRepository.getUsersWhereNot(myId);
      users = users.map((user) => {
        const lowerUserId = myId < user._id ? myId : user._id;
        const higherUserId = myId > user._id ? myId : user._id;
        user.chatId = hash(lowerUserId, higherUserId);
        return user;
      });
      return res.json({
        users,
      });
    } catch (err) {
      return res.json({
        error: true,
        errorMessage: err,
      });
    }
  }

  async getUserProfile(req, res) {
    try {
      User.findOne({ _id: req._id }, (err, user) => {
        if (!user)
          return res
            .status(404)
            .json({ status: false, message: "User record not found." });
        else return res.status(200).json({ status: true, user });
      });
    } catch (err) {
      return res.json({
        error: true,
        errorMessage: err,
      });
    }
  }

  async getUserProfilebyemail(req, res) {
    User.findOne({ email: req.params.email }, (err, docs) => {
      if (!err) {
        res.send({ data: docs });
      } else {
        res.send("Error");
      }
    });
  }

  async saveFcmToken(req, res) {
    try {
      const { fcmToken } = req.body;
      console.log("fcmToken = ", fcmToken);
      const myId = req._id;
      console.log("myId", myId);
      const myUser = await UserRepository.saveUserFcmToken(myId, fcmToken);
      return res.json({
        user: myUser,
      });
    } catch (err) {
      return res.json({
        error: true,
        errorMessage: err,
      });
    }
  }

  async imgupload(req, res) {
    try {
    } catch (err) {
      return res.json({
        error: true,
        errorMessage: err,
      });
    }
  }

  async ChangePassword(req, res) {
    try {
      const { _id, password } = req.body;
      const hash = await bcrypt.hash(password, 10);

      User.findByIdAndUpdate(_id, { password: hash }, function (err, docs) {
        if (err) {
          return res.json({
            error: true,
            errorMessage: "Error Updating, Check again.",
          });
        } else {
          return res.json({
            success: "Password changed successfully!.",
          });
        }
      });
    } catch (err) {
      return res.json({
        error: true,
        errorMessage: "Database Error, Check again.",
      });
    }
  }
}

module.exports = new UserController();
