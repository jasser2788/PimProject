const mongoose = require('mongoose');

const playerSchema = new mongoose.Schema({
    nickname: {
        type: String,
        trim: true,
    },
    socketID: {
        type: String,
    },
    isPartyLeader: {
        type: Boolean,
        default: false
    },
   
})

const playermodel = mongoose.model('Player', playerSchema);
module.exports = {playermodel, playerSchema};