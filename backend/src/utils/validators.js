const { body, validationResult } = require('express-validator');

// Validation middleware to check for errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      errors: errors.array()
    });
  }
  next();
};

// Register validation rules
const validateRegister = [
  body('username')
    .trim()
    .isLength({ min: 3 })
    .withMessage('Username must be at least 3 characters'),
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters'),
  handleValidationErrors
];

// Login validation rules
const validateLogin = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email'),
  body('password')
    .notEmpty()
    .withMessage('Password is required'),
  handleValidationErrors
];

const WASTE_TYPES = ['Biodegradable', 'Non-Biodegradable', 'Hazardous', 'Radio Active'];
const CATEGORIES = ['Compostable', 'Recycle', 'Trash', 'Hazard'];

const validateWasteCreate = [
  body('wasteType').isIn(WASTE_TYPES).withMessage('Invalid wasteType'),
  body('category').isIn(CATEGORIES).withMessage('Invalid category'),
  body('amount').isFloat({ gt: 0 }).withMessage('Amount must be > 0'),
];

const validateWasteUpdate = [
  body('wasteType').optional().isIn(WASTE_TYPES).withMessage('Invalid wasteType'),
  body('category').optional().isIn(CATEGORIES).withMessage('Invalid category'),
  body('amount').optional().isFloat({ gt: 0 }).withMessage('Amount must be > 0'),
];

module.exports = {
  validateRegister,
  validateLogin,
  validateWasteCreate,
  validateWasteUpdate,
  handleValidationErrors
};