const express = require('express');
const cors = require('cors');
const connectDB = require('./config/database');
const config = require('./config/config');
const errorHandler = require('./middleware/error.middleware');

// Import routes
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const wasteRoutes = require('./routes/waste.routes');
const reportRoutes = require('./routes/report.routes');

// Initialize Express app
const app = express();

// Connect to Database
connectDB();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Basic route for testing
app.get('/', (req, res) => {
  res.json({ message: 'Waste Management API is running!' });
});

// API Routes
app.use('/api/auth', authRoutes);
// User routes
app.use('/api/users', userRoutes);
// Waste routes
app.use('/api/waste', wasteRoutes);
// Report routes
app.use('/api/reports', reportRoutes);

// Error handling middleware (must be last)
app.use(errorHandler);

// Start server
const PORT = config.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT} in ${config.NODE_ENV} mode`);
});