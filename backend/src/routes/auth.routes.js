const express = require('express');
const router = express.Router();
const { register, login, getMe } = require('../controllers/auth.controller');
const { validateRegister, validateLogin } = require('../utils/validators');
const { protect } = require('../middleware/auth.middleware');

// Public routes
router.post('/register', validateRegister, register);
router.post('/login', validateLogin, login);

// Protected route (requires authentication)
router.get('/me', protect, getMe);

module.exports = router;