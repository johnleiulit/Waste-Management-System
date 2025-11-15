import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/api_services.dart'; // Assuming this path is correct

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  // Move state variables inside the State class
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _users = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // API Call to fetch the user list
  Future<void> _fetchUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _api.get('/api/users');

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);

        // Check if the response is a Map and contains the 'data' key
        if (decodedBody is Map && decodedBody.containsKey('data')) {
          final dataWrapper = decodedBody['data'] as Map<String, dynamic>;

          // Check if the 'data' object contains the 'users' list
          if (dataWrapper.containsKey('users')) {
            final usersList = dataWrapper['users'];

            if (usersList is List) {
              // Success: Map the list of users
              _users = List<Map<String, dynamic>>.from(
                usersList.map((item) => item as Map<String, dynamic>),
              );
            } else {
              _error = 'Backend error: "users" key is not a list.';
            }
          } else {
            _error = 'Backend error: Missing "users" key in response data.';
          }
        } else {
          // This handles cases where the structure is wrong (e.g., direct list or no 'data' key)
          _error = 'Invalid or unexpected response structure from server.';
        }
      } else {
        // Handle non-200 status codes (like 404, 401, 500)
        final errorBody = jsonDecode(response.body);
        _error =
            'Failed to load users: ${errorBody['message'] ?? 'Status ${response.statusCode}'}';
      }
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // API Call to delete a user
  Future<void> _deleteUser(String userId) async {
    setState(() {
      _loading = true; // Show loading indicator during delete
      _error = null;
    });

    try {
      final response = await _api.delete('/api/users/$userId');

      if (response.statusCode == 200) {
        // If deletion is successful, update the UI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully!')),
        );
        // Re-fetch the list to update the DataTable
        await _fetchUsers();
      } else {
        final errorBody = jsonDecode(response.body);
        _error =
            'Failed to delete user: ${errorBody['message'] ?? response.statusCode}';
      }
    } catch (e) {
      _error = 'An unexpected error occurred during deletion: $e';
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      // Display the error and a refresh button
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _fetchUsers, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      // Fix: Wrap the DataTable in a horizontal SingleChildScrollView
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          // Adjusted spacing to give columns more room
          columnSpacing: 40,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 48,
          horizontalMargin: 8, // Reduce margin to save space
          // Define columns for the user table
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Actions')),
          ],
          // Map the fetched users to DataRow widgets
          rows: _users.map((user) {
            final userId = user['_id'].toString();
            return DataRow(
              cells: [
                DataCell(Text(userId.substring(0, 6))),
                DataCell(Text(user['username'] ?? 'N/A')),
                DataCell(Text(user['email'] ?? 'N/A')),
                DataCell(Text(user['role'] ?? 'user')),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(
                      context,
                      userId,
                      user['username'] ?? 'User',
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Confirmation dialog for deletion
  void _confirmDelete(BuildContext context, String userId, String username) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete user "$username"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteUser(userId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
