const User = function (id, fn, ln, em, ) {
    this.id = id;
    this.nom = fn;
    this.prenom = ln;
    this.email = em;
   
}

module.exports = { User }







/*const mongoose = require("mongoose");

//   YaSSINE.sta@esprit.tn   ==> yassine.sta@esprit.tn
const studentSchema = mongoose.Schema(
    {
        firstName: String,
        lastName: String,
        email: {
            type: String,
            unique: true,
            lowercase: true,
            trim: true,
            required: true
        },
        password: String,
        classe: {
            type: mongoose.Types.ObjectId,
            ref: "classe"
        },
        skills: [
            {
                title: String,
                description: String
            }
        ]
    },
    {
        timestamps: true
    }
);

const calsseSchema = mongoose.Schema(
    {
        label: String
    },
    {
        timestamps: true
    }
);

// var bcrypt = require('bcryptjs');

// studentSchema.pre("save", function (next) {
//     const user = this;
//     let password = user.password;
//     var salt = bcrypt.genSaltSync(10);
//     let hashedPassword = bcrypt.hashSync(password, salt);
//     user.password = hashedPassword;
//     next();
// })

const Student = mongoose.model("student", studentSchema);
const Classe = mongoose.model("classe", calsseSchema);
module.exports = { Student, Classe };
*/