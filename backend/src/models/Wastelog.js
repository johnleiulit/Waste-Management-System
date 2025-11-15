const mongoose = require('mongoose');

const wasteLogSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required']
  },
  username: {
    type: String,
    required: true
  },
  wasteType: {
    type: String,
    required: [true, 'Waste type is required'],
    enum: ['Biodegradable', 'Non-Biodegradable', 'Hazardous', 'Radio Active']
  },
  category: {
    type: String,
    required: true,
    enum: ['Compostable', 'Recycle', 'Trash', 'Hazard']
  },
  amount: {
    type: Number,
    required: [true, 'Amount is required'],
    min: [0, 'Amount cannot be negative']
  },
  totalWeight: {
    type: Number,
    default: function() {
      return this.amount; // Default to amount if not specified
    }
  },
  dateLogged: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Index for faster queries
wasteLogSchema.index({ userId: 1, dateLogged: -1 });
wasteLogSchema.index({ wasteType: 1 });

module.exports = mongoose.model('WasteLog', wasteLogSchema);