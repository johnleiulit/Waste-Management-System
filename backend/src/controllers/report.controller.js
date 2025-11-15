const WasteLog = require('../models/Wastelog');

// GET /api/reports/dashboard  [admin]
// KPIs + recent table for the admin home
exports.getDashboardStats = async (req, res, next) => {
  try {
    const [totalEntries, totalsAgg, recent] = await Promise.all([
      WasteLog.countDocuments({}),
      WasteLog.aggregate([
        { $group: { _id: null, totalWaste: { $sum: '$amount' } } },
        { $project: { _id: 0, totalWaste: 1 } }
      ]),
      WasteLog.find({}).sort({ dateLogged: -1 }).limit(10)
        .select('username wasteType dateLogged amount')
    ]);

    const totalWaste = totalsAgg[0]?.totalWaste || 0;

    res.json({
      success: true,
      data: {
        totalEntries,
        totalReports: totalEntries, // or set your own definition
        totalWaste,
        recent
      }
    });
  } catch (err) { next(err); }
};

// GET /api/reports  [admin]
// Returns aggregation per wasteType for pie chart.
// Query: from, to, category? (optional: limit results by one category)
exports.getReports = async (req, res, next) => {
  try {
    const { from, to, category } = req.query;

    const match = {};
    if (from || to) {
      match.dateLogged = {};
      if (from) match.dateLogged.$gte = new Date(from);
      if (to) {
        const end = new Date(to);
        end.setHours(23, 59, 59, 999);
        match.dateLogged.$lte = end;
      }
    }
    if (category) {
      match.wasteType = category; // or match.category if you prefer
    }

    const pipeline = [
      Object.keys(match).length ? { $match: match } : null,
      { $group: { _id: '$wasteType', totalAmount: { $sum: '$amount' } } },
      { $project: { _id: 0, wasteType: '$_id', totalAmount: 1 } },
      { $sort: { wasteType: 1 } }
    ].filter(Boolean);

    const breakdown = await WasteLog.aggregate(pipeline);
    const grandTotal = breakdown.reduce((s, x) => s + x.totalAmount, 0);

    res.json({
      success: true,
      data: { breakdown, grandTotal }
    });
  } catch (err) { next(err); }
};