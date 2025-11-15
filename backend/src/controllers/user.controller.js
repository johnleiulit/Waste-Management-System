const User = require('../models/User');

// GET /api/users  [admin]
exports.listUsers = async (req, res, next) => {
  try {
    const page = Math.max(parseInt(req.query.page || '1', 10), 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit || '10', 10), 1), 100);
    const skip = (page - 1) * limit;
    const q = (req.query.q || '').trim();

    const criteria = q
      ? { $or: [{ username: new RegExp(q, 'i') }, { email: new RegExp(q, 'i') }] }
      : {};

    const [users, total] = await Promise.all([
      User.find(criteria).select('-password').sort({ createdAt: -1 }).skip(skip).limit(limit),
      User.countDocuments(criteria)
    ]);

    res.json({ success: true, data: { users, total, page, pageSize: users.length } });
  } catch (err) { next(err); }
};

// GET /api/users/:id  [admin or self]
exports.getUser = async (req, res, next) => {
  try {
    const { id } = req.params;
    if (req.user.role !== 'admin' && req.user.id !== id) {
      return res.status(403).json({ success: false, message: 'Forbidden' });
    }
    const user = await User.findById(id).select('-password');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, data: { user } });
  } catch (err) { next(err); }
};

// PUT /api/users/:id  [admin or self]
exports.updateUser = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (req.user.role !== 'admin' && req.user.id !== id) {
      return res.status(403).json({ success: false, message: 'Forbidden' });
    }

    const updates = {};
    const { username, email, password, role } = req.body;

    if (username) updates.username = username.trim();
    if (email) updates.email = email.trim().toLowerCase();
    // Only admin can change role
    if (role && req.user.role === 'admin') updates.role = role;

    let user = await User.findById(id).select('+password');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    // Apply updates
    Object.assign(user, updates);
    if (password) user.password = password; // will hash via pre('save')

    await user.save();
    user = user.toObject();
    delete user.password;

    res.json({ success: true, message: 'User updated', data: { user } });
  } catch (err) { next(err); }
};

// DELETE /api/users/:id  [admin]
exports.deleteUser = async (req, res, next) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Admin only' });
    }
    const { id } = req.params;
    const user = await User.findByIdAndDelete(id);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, message: 'User deleted' });
  } catch (err) { next(err); }
};