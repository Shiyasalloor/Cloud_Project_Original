const express = require('express');
const router = express.Router();
const Content = require('../models/Content'); // Ensure the path is correct

// Get limited data for homepage (current happenings)
router.get('/homepage', async (req, res) => {
    try {
        const announcements = await Content.find({ category: 'announcement' })
            .sort({ date: -1 })
            .limit(3);
        const events = await Content.find({ category: 'event' })
            .sort({ date: -1 })
            .limit(3);
        const clubs = await Content.find({ category: 'club' })
            .sort({ date: -1 })
            .limit(3);

        res.json({
            announcements,
            events,
            clubs,
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get all entries for a specific category (announcements, events, clubs)
router.get('/:category', async (req, res) => {
    const category = req.params.category;
    try {
        const content = await Content.find({ category });
        res.json(content);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get specific content by ID
router.get('/:category/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const content = await Content.findById(id);
        if (!content) {
            return res.status(404).json({ msg: 'Content not found' });
        }
        res.json(content);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Add new entry for any category
router.post('/add', async (req, res) => {
    const { title, description, contents, type } = req.body;

    // Validate the type
    const validTypes = ['announcement', 'event', 'club'];
    if (!validTypes.includes(type)) {
        return res.status(400).json({ msg: 'Invalid category type' });
    }

    try {
        const newContent = new Content({
            title,
            category: type, // Use the correct category from the request
            description,
            contents
        });

        const savedContent = await newContent.save();
        res.status(201).json(savedContent);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
