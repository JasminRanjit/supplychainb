const mongoose = require('mongoose');

const AccountSchema = mongoose.Schema({
    name: String,
    role: String,
    cardName: String,
    userID: String,
}, {
    timestamps: true
});

module.exports = mongoose.model('Account', AccountSchema);