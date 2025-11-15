import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../auth/login_screen.dart';
import '../../widgets/navigation_drawer.dart' as app_drawer;

import '../../screen/admin/user_list_screen.dart';
import '../../screen/admin/all_waste_logs_screen.dart';
import 'reports_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // 1. Add state to track the current selected menu item
  app_drawer.AdminMenuItem _selectedItem = app_drawer.AdminMenuItem.home;

  @override
  void initState() {
    super.initState();
    // Fetch stats only when the widget is initialized and the current item is Home
    if (_selectedItem == app_drawer.AdminMenuItem.home) {
      Future.microtask(() => context.read<DashboardProvider>().fetchStats());
    }
  }

  // Helper method to handle menu item selection
  void _onMenuItemSelected(app_drawer.AdminMenuItem item) {
    if (item == _selectedItem) return; // Don't rebuild if already selected

    setState(() {
      _selectedItem = item;
    });

    // You would typically navigate to a new screen or update the 'body' widget here
    // based on the selected 'item'.
    if (item == app_drawer.AdminMenuItem.home) {
      // Re-fetch data if navigating back to home
      context.read<DashboardProvider>().fetchStats();
    }
  }

  // Helper method to handle logout
  void _onLogout() {
    // Navigate to the login screen and prevent back navigation
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // Helper method to get the widget for the currently selected menu item
  Widget _getBodyForSelectedItem(DashboardProvider dashboard) {
    switch (_selectedItem) {
      case app_drawer.AdminMenuItem.home:
        return _buildHomeBody(dashboard);
      case app_drawer.AdminMenuItem.users:
        return const UserListScreen();
      case app_drawer.AdminMenuItem.allWasteLogs:
        return const AllWasteLogsScreen();
      case app_drawer.AdminMenuItem.reports:
        return const ReportsScreen();
      case app_drawer.AdminMenuItem.settings:
        return const Center(child: Text('Settings Screen'));
    }
  }

  // Your original dashboard content moved into a reusable helper method
  Widget _buildHomeBody(DashboardProvider dashboard) {
    if (dashboard.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (dashboard.error != null) {
      return Center(child: Text('Error: ${dashboard.error!}'));
    } else if (dashboard.stats == null) {
      return const Center(child: Text('No dashboard data available.'));
    } else {
      final data = dashboard.stats!;
      final cards = [
        _InfoCard(title: 'Total Entries', value: data['totalEntries'].toString()),
        _InfoCard(title: 'Total Reports', value: data['totalReports'].toString()),
        // Ensure totalWaste is handled, maybe assume it's a number and format it
        _InfoCard(title: 'Total Waste', value: '${data['totalWaste'] ?? 0} kg'), 
      ];

      final recent = List<Map<String, dynamic>>.from(data['recent'] ?? []);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Cards
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: cards,
            ),
            const SizedBox(height: 24),
            // Recent Logs Table
            const Text('Recent Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, // Ensures the table takes full width
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Username')),
                  DataColumn(label: Text('Waste Type')),
                  DataColumn(label: Text('Date Logged')),
                  DataColumn(label: Text('Amount')),
                ],
                rows: recent.map((log) {
                  final date = DateTime.tryParse(log['dateLogged'] ?? '');
                  final formatted = date != null ? '${date.month}/${date.day}/${date.year}' : '-';
                  return DataRow(cells: [
                    DataCell(Text(log['username'] ?? 'N/A')),
                    DataCell(Text(log['wasteType'] ?? 'N/A')),
                    DataCell(Text(formatted)),
                    DataCell(Text('${log['amount'] ?? 0}')),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();

    return Scaffold(
      appBar: AppBar(
        // Update the title dynamically based on the selected item
        title: Text('${_selectedItem.toString().split('.').last.toUpperCase()} | Admin'),
        actions: [
          // Logout action in AppBar (redundant since it's in the drawer, but kept for simplicity)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _onLogout,
          )
        ],
      ),
      // 2. Attach the AdminNavigationDrawer to the Scaffold
      drawer: app_drawer.AdminNavigationDrawer(
        selectedItem: _selectedItem, // Pass the current selected state
        onSelectItem: _onMenuItemSelected, // Pass the selection handler
        onLogout: _onLogout, // Pass the logout handler
      ),
      // 3. Use the helper method to display the correct screen body
      body: _getBodyForSelectedItem(dashboard),
    );
  }
}

// Info Card remains unchanged
class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22)),
        ],
      ),
    );
  }
}