const WasteLog = require('../models/Wastelog');

// POST /api/waste  [auth]
exports.createWaste = async (req, res, next) => {
  try {
    const { wasteType, category, amount, dateLogged } = req.body;

    const log = await WasteLog.create({
      userId: req.user._id,
      username: req.user.username,
      wasteType,
      category,
      amount,
      dateLogged: dateLogged ? new Date(dateLogged) : undefined
    });

    res.status(201).json({ success: true, data: { log } });
  } catch (err) { next(err); }
};

// GET /api/waste  [auth]  (admin: all, user: own) + filters
exports.listWaste = async (req, res, next) => {
  try {
    const page = Math.max(parseInt(req.query.page || '1', 10), 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit || '10', 10), 1), 100);
    const skip = (page - 1) * limit;

    const { category, wasteType, userId, from, to, q } = req.query;

    const criteria = {};

    // Role-based access
    if (req.user.role !== 'admin') {
      criteria.userId = req.user._id;
    } else if (userId) {
      criteria.userId = userId;
    }

    if (category) criteria.category = category;
    if (wasteType) criteria.wasteType = wasteType;

    // Date range
    if (from || to) {
      criteria.dateLogged = {};
      if (from) criteria.dateLogged.$gte = new Date(from);
      if (to) {
        const end = new Date(to);
        end.setHours(23, 59, 59, 999);
        criteria.dateLogged.$lte = end;
      }
    }

    // Simple text search on username
    if (q) criteria.username = new RegExp(q.trim(), 'i');

    const [logs, total] = await Promise.all([
      WasteLog.find(criteria).sort({ dateLogged: -1 }).skip(skip).limit(limit),
      WasteLog.countDocuments(criteria)
    ]);

    res.json({ success: true, data: { logs, total, page, pageSize: logs.length } });
  } catch (err) { next(err); }
};

// GET /api/waste/recent  [admin]
exports.recentWaste = async (req, res, next) => {
  try {
    const limit = Math.min(parseInt(req.query.limit || '10', 10), 50);
    const logs = await WasteLog.find({}).sort({ dateLogged: -1 }).limit(limit);
    res.json({ success: true, data: { logs } });
  } catch (err) { next(err); }
};

// GET /api/waste/:id  [auth] (owner or admin)
exports.getWaste = async (req, res, next) => {
  try {
    const log = await WasteLog.findById(req.params.id);
    if (!log) return res.status(404).json({ success: false, message: 'Log not found' });

    if (req.user.role !== 'admin' && log.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Forbidden' });
    }

    res.json({ success: true, data: { log } });
  } catch (err) { next(err); }
};

// PUT /api/waste/:id  [auth] (owner or admin)
exports.updateWaste = async (req, res, next) => {
  try {
    const log = await WasteLog.findById(req.params.id);
    if (!log) return res.status(404).json({ success: false, message: 'Log not found' });

    if (req.user.role !== 'admin' && log.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Forbidden' });
    }

    const { wasteType, category, amount, dateLogged } = req.body;
    if (wasteType) log.wasteType = wasteType;
    if (category) log.category = category;
    if (amount !== undefined) log.amount = amount;
    if (dateLogged) log.dateLogged = new Date(dateLogged);

    await log.save();
    res.json({ success: true, message: 'Log updated', data: { log } });
  } catch (err) { next(err); }
};

// DELETE /api/waste/:id  [auth] (owner or admin)
exports.deleteWaste = async (req, res, next) => {
  try {
    const log = await WasteLog.findById(req.params.id);
    if (!log) return res.status(404).json({ success: false, message: 'Log not found' });

    if (req.user.role !== 'admin' && log.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Forbidden' });
    }

    await WasteLog.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Log deleted' });
  } catch (err) { next(err); }
};