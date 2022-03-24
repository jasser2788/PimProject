const express = require("express");
const router = express.Router();
const UserController = require("./controllers/UserController");
const userMiddleware = require("./middlewares/auths/user");
const userx = require("./models/UserModel");
const multer = require("multer");
let url = "";

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "./uploads/");
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + file.originalname);
  },
});

const fileFilter = (req, file, cb) => {
  // reject a file
  if (file.mimetype === "image/jpeg" || file.mimetype === "image/png") {
    cb(null, true);
  } else {
    cb(null, false);
  }
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 1024 * 1024 * 5,
  },
  fileFilter: fileFilter,
});

const middlewares = {
  user: userMiddleware,
};

router.get("/", (req, res) => {
  return res.json("backend server working properly").status(200);
});

router.post("/auth", UserController.login);
router.post("/user", UserController.create);
router.get("/users", UserController.getUsers);
router.get("/userprofile", [middlewares.user], UserController.getUserProfile);
router.get("/userprofilebyemail/:email", UserController.getUserProfilebyemail);
router.post("/modifyuser", UserController.modify);
router.post("/ChangePassword", UserController.ChangePassword);
router.delete("/users/delete/:id", UserController.delete);
router.post("/verifyemail/:email/:nb", UserController.verifyemail);
//Orders
router.post("/fcm-token", [middlewares.user], UserController.saveFcmToken);

router.use("/uploads", express.static(__dirname + "/uploads"));

router.post(
  "/updateImg",
  upload.single("profilepic"),
  async (req, res, next) => {
    console.log("updating...");
    url = req.protocol + "://" + req.get("host");
    userx.findOneAndUpdate(
      { email: req.body.email },
      {
        $set: {
          profilepic: url + "/uploads/" + req.file.filename,
        },
      },
      { new: true },
      (err, userx) => {
        if (err) return res.status(500).send(err);
        const response = {
          data: userx.profilepic,
        };
        return res.status(200).send(response);
      }
    );
  }
);

module.exports = router;
