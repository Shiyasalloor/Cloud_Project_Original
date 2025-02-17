// routes/auth.js
const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require("../models/User");
const router = express.Router();

// POST /signup - Register a new user
// POST /signup - Register a new user
router.post('/signup', async (req, res) => {
  const { username, email, password } = req.body;
  console.log("signup called")
  try {
    // Check if user already exists
    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ msg: 'User already exists' });
    }

    // Hash the password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create new user
    user = new User({
      username,
      email,
      password: hashedPassword, // Save the hashed password
    });

    await user.save();

    // Generate JWT token
    const token = jwt.sign({ userId: user.id }, 'secretkey', {
      expiresIn: '1h',
    });

    res.status(201).json({ token });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});


// POST /signin - Authenticate user & get token
// POST /signin - Authenticate user & get token
// POST /signin - Authenticate user & get token
router.post('/signin', async (req, res) => {
  const { email, password } = req.body;

  try {
    console.log("Signin called with email:", email);

    // Check if user exists
    const user = await User.findOne({ email });
    if (!user) {
      console.log("User not found");
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    console.log("Hashed password from DB:", user.password);

    // Match the password using bcrypt
    const isMatch = await bcrypt.compare(password, user.password);
    console.log("Password comparison result:", isMatch);

    if (!isMatch) {
      console.log("Password does not match");
      return res.status(400).json({ msg: 'Invalid credentials' });
    }
    
    console.log("Signin successful for user:", user);
    res.status(200).json({ username : user.username });
  } catch (err) {
    console.error("Error in signin:", err.message);
    res.status(500).send('Server error');
  }
});


module.exports = router;
