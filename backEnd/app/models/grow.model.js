const mongoose = require('mongoose');

const GrowSchema = mongoose.Schema({
    grow: string
}, {
    timestamps: true
});

module.exports = mongoose.model('Grow', GrowSchema);