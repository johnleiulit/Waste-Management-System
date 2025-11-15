import 'package:flutter/material.dart';

// The enum defines the possible menu items
enum AdminMenuItem {
  home,
  users,
  allWasteLogs,
  reports,
  settings,
}

// The main widget for the Navigation Drawer
class AdminNavigationDrawer extends StatelessWidget {
  const AdminNavigationDrawer({
    super.key,
    required this.selectedItem,
    this.onSelectItem,
    this.onLogout,
  });

  // Properties to manage the selected state and actions
  final AdminMenuItem selectedItem;
  final ValueChanged<AdminMenuItem>? onSelectItem;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        // Light blue background for the drawer
        color: const Color(0xFFE3F2FD),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header with profile info and close button
              _buildHeader(context),
              const SizedBox(height: 24),
              // 2. Scrollable Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuTile(context, AdminMenuItem.home, 'Home', Icons.home),
                    _buildMenuTile(context, AdminMenuItem.users, 'Users', Icons.people),
                    _buildMenuTile(context, AdminMenuItem.allWasteLogs, 'All Waste Logs', Icons.recycling),
                    _buildMenuTile(context, AdminMenuItem.reports, 'Reports', Icons.bar_chart),
                    _buildMenuTile(context, AdminMenuItem.settings, 'Settings', Icons.settings),
                  ],
                ),
              ),
              // 3. Logout Section
              const Divider(),
              _buildLogoutTile(context),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for the Drawer Header
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(), // Closes the drawer
            ),
          ),
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 32, color: Colors.blueAccent),
          ),
          const SizedBox(height: 12),
          const Text(
            'Admin',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'admin@wasteapp.com', // placeholder
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Helper method for a single menu tile
  Widget _buildMenuTile(
    BuildContext context,
    AdminMenuItem item,
    String label,
    IconData icon,
  ) {
    // Check if this item is currently selected
    final bool isSelected = item == selectedItem;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        // Highlight color if selected
        color: isSelected ? const Color(0xFF90CAF9) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: Colors.black87),
          title: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onTap: () {
            Navigator.of(context).pop(); // Close drawer
            onSelectItem?.call(item); // Call the provided callback
          },
        ),
      ),
    );
  }

  // Helper method for the Logout button
  Widget _buildLogoutTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF90CAF9),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.of(context).pop();
          onLogout?.call(); // Call the provided callback
        },
      ),
    );
  }
}