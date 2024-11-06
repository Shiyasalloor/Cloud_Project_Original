const mongoose = require('mongoose');

// Schema for content (announcements, events, clubs)
const contentSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true
    },
    category: {
        type: String,
        enum: ['announcement', 'event', 'club'], // Adjusted to singular for consistency
        required: true
    },
    description: {
        type: String,
        required: true
    },
    date: { 
        type: Date, 
        default: Date.now 
    }, 
    contents: {
        type: String,
        required: true
    }
});

module.exports = mongoose.model('Content', contentSchema);
