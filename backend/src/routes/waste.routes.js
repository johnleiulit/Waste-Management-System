const express = require('express');
const router = express.Router();
const { protect, admin } = require('../middleware/auth.middleware');
const {
  createWaste, listWaste, recentWaste, getWaste, updateWaste, deleteWaste
} = require('../controllers/waste.controller');
const { validateWasteCreate, validateWasteUpdate, handleValidationErrors } = require('../utils/validators');

router.use(protect);

router.post('/', validateWasteCreate, handleValidationErrors, createWaste);
router.get('/', listWaste);
router.get('/recent', admin, recentWaste);

router.get('/:id', getWaste);
router.put('/:id', validateWasteUpdate, handleValidationErrors, updateWaste);
router.delete('/:id', deleteWaste);

module.exports = router;