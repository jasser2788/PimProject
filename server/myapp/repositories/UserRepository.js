const User = require('../models/UserModel');
const ObjectId = require('mongoose').Types.ObjectId;

class UserRepository {

    async create({ name, email, username, password, type, profilepic }) {
        await User.create({
            email,
            username,
            password,
            profilepic

        });
    }
    async findUserById(id) {
        return await User.findOne({_id: id});
    }
    async delete(id) {
        await User.findOneAndDelete({ _id: ObjectId(id)});
    }
    async update(id, user) {
        await User.findOneAndUpdate({ _id: ObjectId(id)},{$set: user});
    }
    async findByUsername(username) {
        return await User.findOne({ username }).select({ 'name': 1, 'username': 1, 'password': 1, 'email': 1, 'type': 1, 'profilepic': 1 });
    }
    async findByEmail(email) {
        return await User.findOne({ email }).select({ 'profilepic': 1, 'name': 1, 'username': 1, 'password': 1, 'email': 1, 'type':1, 'profilepic': 1 });
    }

    async getUsersWhereNot(userId) {
        return await User.find({ _id: { $ne: ObjectId(userId) } });
    }

    async getUserByName(myId, name) {
        return await User.find({
            _id: { $ne: ObjectId(myId), name }
        });
    }

    async saveUserFcmToken(userId, fcmToken) {
        return await User.updateOne({ _id: ObjectId(userId) }, {
            fcmToken
        });
    }


}

module.exports = new UserRepository();
