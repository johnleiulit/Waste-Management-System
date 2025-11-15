const express = require('express');
const router = express.Router();
const { protect, admin } = require('../middleware/auth.middleware');
const { listUsers, getUser, updateUser, deleteUser } = require('../controllers/user.controller');

// All routes require auth
router.use(protect);

// List users (admin)
router.get('/', admin, listUsers);

// Read/update self or admin
router.get('/:id', getUser);
router.put('/:id', updateUser);

// Delete (admin)
router.delete('/:id', admin, deleteUser);

module.exports = router;