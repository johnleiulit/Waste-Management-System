import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/waste_provider.dart';

class AllWasteLogsScreen extends StatefulWidget {
  const AllWasteLogsScreen({super.key});

  @override
  State<AllWasteLogsScreen> createState() => _AllWasteLogsScreenState();
}

class _AllWasteLogsScreenState extends State<AllWasteLogsScreen> {
  // Filter state
  String? _selectedCategory;
  String? _selectedWasteType;
  DateTime? _fromDate;
  DateTime? _toDate;
  final _searchController = TextEditingController();
  final int _itemsPerPage = 10;

  final List<String> _categories = [
    'Compostable',
    'Recycle',
    'Trash',
    'Hazard',
  ];

  final List<String> _wasteTypes = [
    'Biodegradable',
    'Non-Biodegradable',
    'Hazardous',
    'Radio Active',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchLogs());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLogs({int page = 1}) async {
    final provider = context.read<WasteProvider>();
    await provider.fetchAllLogs(
      page: page,
      limit: _itemsPerPage,
      category: _selectedCategory,
      wasteType: _selectedWasteType,
      from: _fromDate?.toIso8601String().split('T')[0],
      to: _toDate?.toIso8601String().split('T')[0],
      searchQuery: _searchController.text.trim().isEmpty 
          ? null 
          : _searchController.text.trim(),
    );
  }

  void _applyFilters() {
    setState(() {});
    _fetchLogs(page: 1);
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedWasteType = null;
      _fromDate = null;
      _toDate = null;
      _searchController.clear();
    });
    _fetchLogs(page: 1);
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
    }
  }

  Future<void> _deleteLog(String logId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this waste log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<WasteProvider>();
      final success = await provider.deleteLog(logId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Log deleted successfully')),
          );
          _fetchLogs(page: provider.currentPage);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to delete log'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    final date = DateTime.tryParse(dateString);
    if (date == null) return '-';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WasteProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Waste Logs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: ExpansionTile(
              title: const Text(
                'Filters',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              initiallyExpanded: false,
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search by Username',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ..._categories.map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                  },
                ),
                const SizedBox(height: 12),
                
                // Waste Type Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedWasteType,
                  decoration: const InputDecoration(
                    labelText: 'Waste Type',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Waste Types'),
                    ),
                    ..._wasteTypes.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedWasteType = value);
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
                            labelText: 'From Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _fromDate == null
                                ? 'Select date'
                                : _formatDate(_fromDate!.toIso8601String()),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'To Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _toDate == null
                                ? 'Select date'
                                : _formatDate(_toDate!.toIso8601String()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearFilters,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Clear'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: _buildContent(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(WasteProvider provider) {
    if (provider.isLoading && provider.logs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.logs.isEmpty) {
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
              onPressed: () => _fetchLogs(page: provider.currentPage),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.logs.isEmpty) {
      return const Center(
        child: Text(
          'No waste logs found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // Data Table
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 40,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 72,
                columns: const [
                  DataColumn(label: Text('Username')),
                  DataColumn(label: Text('Waste Type')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Amount (kg)')),
                  DataColumn(label: Text('Date Logged')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: provider.logs.map((log) {
                  return DataRow(
                    cells: [
                      DataCell(Text(log['username'] ?? 'N/A')),
                      DataCell(Text(log['wasteType'] ?? 'N/A')),
                      DataCell(Text(log['category'] ?? 'N/A')),
                      DataCell(Text('${log['amount'] ?? 0}')),
                      DataCell(Text(_formatDate(log['dateLogged']))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              iconSize: 20,
                              onPressed: () => _deleteLog(log['_id'] ?? ''),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        
        // Pagination Controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: provider.currentPage > 1
                    ? () => _fetchLogs(page: provider.currentPage - 1)
                    : null,
              ),
              Text(
                'Page ${provider.currentPage} of ${(provider.totalLogs / _itemsPerPage).ceil()} (Total: ${provider.totalLogs})',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: provider.currentPage < (provider.totalLogs / _itemsPerPage).ceil()
                    ? () => _fetchLogs(page: provider.currentPage + 1)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}