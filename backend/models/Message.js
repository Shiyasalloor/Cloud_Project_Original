// Message.js (Backend Model)
const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
    text: { type: String, required: true },
    username: { type: String, required: true },
    timestamp: { type: String, required: true }, // ISO string format
});

module.exports = mongoose.model('Message', messageSchema);
