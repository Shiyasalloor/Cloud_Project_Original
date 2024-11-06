const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const Message = require('./models/Message'); // Import the Message model

// Environment configuration
dotenv.config();

// Initialize express app
const app = express();
const server = http.createServer(app); // Create server for Socket.IO
const io = new Server(server);

// Middleware to handle JSON and CORS
app.use(express.json());
app.use(cors());

// MongoDB connection
mongoose.connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => console.log('MongoDB connected'))
.catch((err) => console.error(err));

// Import routes
const contentRoutes = require('./routes/contentRoutes'); // For homepage data
const authRoutes = require('./routes/auth'); // For signup/signin

// Route Middleware
app.use('/api/auth', authRoutes); // User Authentication Routes
app.use('/api/content', contentRoutes); // Routes for announcements, events, clubs, and workshops

app.get('/api/messages', async (req, res) => {
    console.log('hi')
    try {
        const messages = await Message.find().sort({ timestamp:1 }).limit(50); // Fetch the latest 50 messages
        res.status(200).json(messages);
    } catch (error) {
        res.status(500).send('Error fetching messages');
    }
});
// Import and set up the messaging routes
const setupMessageRoutes = require('./routes/messageRoutes');
setupMessageRoutes(io); // Initialize Socket.IO event listeners for messaging

// Start the server
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
