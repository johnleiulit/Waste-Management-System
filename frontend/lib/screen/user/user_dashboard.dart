import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/waste_provider.dart';
import '../auth/login_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final _formKey = GlobalKey<FormState>();
  String _wasteType = 'Biodegradable';
  String _category = 'Compostable';
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  String? _editingLogId;

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to call fetchMyLogs after the build process starts
    Future.microtask(() => context.read<WasteProvider>().fetchMyLogs());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _startEdit(Map<String, dynamic> log) {
    setState(() {
      _editingLogId = log['_id'] ?? log['id'];
      _wasteType = log['wasteType'] ?? 'Biodegradable';
      _category = log['category'] ?? 'Compostable';
      _amountController.text = (log['amount'] ?? 0).toString();
      final dateStr = log['dateLogged'];
      _selectedDate = dateStr != null ? DateTime.tryParse(dateStr) : null;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingLogId = null;
      _wasteType = 'Biodegradable';
      _category = 'Compostable';
      _amountController.clear();
      _selectedDate = null;
    });
  }

  Future<void> _deleteLog(String logId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final wasteProvider = context.read<WasteProvider>();
      final success = await wasteProvider.deleteLog(logId);
      
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Waste log deleted')),
        );
      } else {
        final error = wasteProvider.error ?? 'Failed to delete log';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }


  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final wasteProvider = context.read<WasteProvider>();
    bool success;

    if (_editingLogId != null) {
      // Update existing log
      success = await wasteProvider.updateLog(
        logId: _editingLogId!,
        wasteType: _wasteType,
        category: _category,
        amount: double.parse(_amountController.text),
        dateLogged: _selectedDate,
      );
    } else {
      // Create new log
      success = await wasteProvider.createLog(
        wasteType: _wasteType,
        category: _category,
        amount: double.parse(_amountController.text),
        dateLogged: _selectedDate,
      );
    }

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editingLogId != null ? 'Waste log updated' : 'Waste log submitted',
          ),
        ),
      );
      _cancelEdit(); // Reset form
    } else {
      final error = wasteProvider.error ?? 'Failed to submit';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final wasteProvider = context.watch<WasteProvider>();

    final wasteTypes = const [
      'Biodegradable',
      'Non-Biodegradable',
      'Hazardous',
      'Radio Active',
    ];

    final categories = const [
      'Compostable', // Simplified from 'Compost Ready'
      'Recycle', // Simplified from 'Recyclable'
      'Trash', // For non-recyclable general waste
      'Hazard', // For specific hazardous waste
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Waste Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Note: You should probably call an AuthProvider logout method here
              // before navigating, to clear any tokens.
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FIX: Dynamic Form Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _editingLogId != null ? 'Edit Waste Log' : 'Submit New Log',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_editingLogId != null)
                  TextButton(
                    onPressed: _cancelEdit,
                    child: const Text('Cancel Edit'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _wasteType,
                        items: wasteTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        decoration: const InputDecoration(
                          labelText: 'Waste Type',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _wasteType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _category,
                        items: categories
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _category = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount (kg)',
                        ),
                        validator: (value) {
                          final parsed = double.tryParse(value ?? '');
                          if (parsed == null || parsed <= 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'Date: Today'
                                  : 'Date: ${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate ?? now, // Use selected date if available
                                firstDate: DateTime(now.year - 1),
                                lastDate: DateTime(now.year + 1),
                              );
                              if (date != null) {
                                setState(() => _selectedDate = date);
                              }
                            },
                            child: const Text('Pick Date'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: wasteProvider.isLoading ? null : _submit,
                          child: wasteProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _editingLogId != null ? 'Update Log' : 'Submit Log',
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'My Logs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (wasteProvider.isLoading && wasteProvider.logs.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (wasteProvider.error != null)
              Text(
                wasteProvider.error!,
                style: const TextStyle(color: Colors.red),
              )
            else if (wasteProvider.logs.isEmpty)
              const Text('No logs yet.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: wasteProvider.logs.length,
                itemBuilder: (context, index) {
                  final log = wasteProvider.logs[index];
                  // Use '_id' if available, otherwise fall back to 'id'
                  final logId = log['_id'] ?? log['id'] as String;
                  final date = DateTime.tryParse(log['dateLogged'] ?? '');
                  final formatted = date != null
                      ? '${date.month}/${date.day}/${date.year}'
                      : '-';
                  return Card(
                    child: ListTile(
                      title: Text('${log['wasteType']} - ${log['amount']} kg'),
                      subtitle: Text(
                        'Category: ${log['category']} • $formatted',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _startEdit(log),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _deleteLog(logId),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}