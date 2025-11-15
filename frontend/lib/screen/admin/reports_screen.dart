import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/report_provider.dart';
  
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedCategory = 'All';
  DateTime? _fromDate;
  DateTime? _toDate;

  final List<String> _categories = [
    'All',
    'Biodegradable',
    'Non-Biodegradable',
    'Hazardous',
    'Radio Active',
  ];

  // Color mapping for each waste type
  final Map<String, Color> _wasteTypeColors = {
    'Biodegradable': Colors.yellow,
    'Non-Biodegradable': Colors.blue,
    'Hazardous': Colors.pink,
    'Radio Active': Colors.green,
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchReports());
  }

  Future<void> _fetchReports() async {
    final provider = context.read<ReportsProvider>();
    await provider.fetchReports(
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      from: _fromDate?.toIso8601String().split('T')[0],
      to: _toDate?.toIso8601String().split('T')[0],
    );
  }

  Future<void> _pickDate(bool isFromDate) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: isFromDate ? (_fromDate ?? now) : (_toDate ?? now),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (date != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = date;
        } else {
          _toDate = date;
        }
      });
      _fetchReports();
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Pick a Date';
    return '${date.month}/${date.day}/${date.year}';
  }

  List<PieChartSectionData> _buildPieChartSections(
    List<Map<String, dynamic>> breakdown,
    double total,
  ) {
    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey[300],
          title: 'No Data',
          radius: 100,
        ),
      ];
    }

    return breakdown.map((item) {
      final wasteType = item['wasteType'] ?? 'Unknown';
      final amount = (item['totalAmount'] ?? 0).toDouble();

      // Get color for this waste type
      final color = _wasteTypeColors[wasteType] ?? Colors.grey;

      return PieChartSectionData(
        value: amount,
        color: color,
        title: '$wasteType $amount',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                    _fetchReports();
                  },
                ),
                const SizedBox(height: 12),
                
                // Date Range
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'From',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(_formatDate(_fromDate)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'To',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(_formatDate(_toDate)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chart Section
          Expanded(
            child: _buildChartContent(provider),
          ),

          // Total Waste Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.red,
            child: Text(
              'Total Waste: ${provider.grandTotal.toInt()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContent(ReportsProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${provider.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchReports,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.breakdown.isEmpty || provider.grandTotal == 0) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Pie Chart
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(
                    provider.breakdown,
                    provider.grandTotal,
                  ),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Legend
            ...provider.breakdown.map((item) {
              final wasteType = item['wasteType'] ?? 'Unknown';
              final amount = item['totalAmount'] ?? 0;
              final color = _wasteTypeColors[wasteType] ?? Colors.grey;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$wasteType: $amount',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}