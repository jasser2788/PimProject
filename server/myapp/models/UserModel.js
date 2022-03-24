const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const UserSchema = mongoose.Schema({
   
    email: {
        type: String,
        required: true,
    },
    username: {
        type: String,
        required: true,
    },
    
    profilepic: {
        type: String,
        required: false,
        default: "http://localhost:8081/uploads/defaultpic.png"
    },
    password: {
        type: String,
        required: true,
        select: false,
    
    },
    fcmToken: String,
    chatId: String,
    createdAt: {
        type: Number,
        default: Date.now
    }
});

UserSchema.pre('save', async function(next) {
    const hash = await bcrypt.hash(this.password, 10);
    this.password = hash;
    next();
});

module.exports = mongoose.model('User', UserSchema);
