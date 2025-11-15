const express = require('express');
const router = express.Router();
const { protect, admin } = require('../middleware/auth.middleware');
const { getDashboardStats, getReports } = require('../controllers/report.controller');

router.use(protect, admin);

router.get('/dashboard', getDashboardStats);
router.get('/', getReports);

module.exports = router;