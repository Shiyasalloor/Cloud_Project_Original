// messageRoutes.js
const express = require('express');
const router = express.Router();
const Message = require('../models/Message'); // Adjust the path as needed

function setupMessageRoutes(io) {
    // Socket.IO connection event listener
    io.on('connection', (socket) => {
        console.log('A user connected to the messaging system');

        // Emit previous messages when a user connects
        Message.find()
            .then((messages) => {
                socket.emit('previousMessages', messages);
            })
            .catch(err => console.error(err));

        // Listen for message sending
        socket.on('sendMessage', (data) => {
            const newMessage = new Message(data);
            newMessage.save()
                .then(() => {
                    io.emit('newMessage', data); // Broadcast message to all clients
                })
                .catch(err => console.error(err));
        });

        // Handle request for previous messages
        socket.on('requestPreviousMessages', () => {
            Message.find()
                .then((messages) => {
                    socket.emit('previousMessages', messages);
                })
                .catch(err => console.error(err));
        });

        socket.on('disconnect', () => {
            console.log('A user disconnected from the messaging system');
        });
    });
}

module.exports = setupMessageRoutes;
