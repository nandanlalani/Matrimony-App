import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../string_const.dart';
import '../backend/Database.dart';
import 'add_profile_screen.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _users = [];
  String searchQuery = "";
  String? _sortCriteria;
  bool _isAscending = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _apiService.fetchUsers(context);
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load users'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _sortUsers() {
    setState(() {
      if (_sortCriteria == 'Name') {
        _users.sort((a, b) => _isAscending
            ? a[FNAME].toLowerCase().compareTo(b[FNAME].toLowerCase())
            : b[FNAME].toLowerCase().compareTo(a[FNAME].toLowerCase()));
      } else if (_sortCriteria == 'Age') {
        _users.sort((a, b) {
          final dobA = DateFormat('dd/MM/yyyy').parse(a['dob']);
          final dobB = DateFormat('dd/MM/yyyy').parse(b['dob']);
          return _isAscending ? dobA.compareTo(dobB) : dobB.compareTo(dobA);
        });
      } else if (_sortCriteria == 'City') {
        _users.sort((a, b) => _isAscending
            ? a[CITY].toLowerCase().compareTo(b[CITY].toLowerCase())
            : b[CITY].toLowerCase().compareTo(a[CITY].toLowerCase()));
      }
    });
  }

  Future<void> _toggleFavorite(String userId, int currentStatus) async {
    try {
      await _apiService.updateUser(context, userId, {FAV: currentStatus == 1 ? 0 : 1});
      _fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update favorite status'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteUser(String userId) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete) {
      try {
        await _apiService.deleteUser(context, userId);
        _fetchUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete user'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Confirm Delete",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF5A8C)),
        ),
        content: const Text(
          "Are you sure you want to delete this user? This action cannot be undone.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        buttonPadding: const EdgeInsets.all(15),
      ),
    ) ?? false;
  }

  void _editUser(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProfileScreen(userData: user, userId: user[ID]),
      ),
    ).then((_) => _fetchUsers());
  }

  void _viewUserDetails(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailScreen(userId: userId),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredUsers() {
    if (searchQuery.isEmpty) return _users;

    return _users.where((user) {
      final hobbies = (user['hobbies'] as List<dynamic>?)?.join(', ') ?? '';
      return user[FNAME].toLowerCase().contains(searchQuery.toLowerCase()) ||
          user[LNAME].toLowerCase().contains(searchQuery.toLowerCase()) ||
          user[EMAIL].toLowerCase().contains(searchQuery.toLowerCase()) ||
          user[NUMBER].toLowerCase().contains(searchQuery.toLowerCase()) ||
          user["dob"].toLowerCase().contains(searchQuery.toLowerCase()) ||
          user[CITY].toLowerCase().contains(searchQuery.toLowerCase()) ||
          hobbies.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user[GENDER].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFF5A8C),
        title: const Text(
          "User Directory",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search users...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        searchQuery = "";
                      });
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (String value) {
              if (value == 'Name Ascending' || value == 'Name Descending') {
                _sortCriteria = 'Name';
                _isAscending = value == 'Name Ascending';
              } else if (value == 'City Ascending' || value == 'City Descending') {
                _sortCriteria = 'City';
                _isAscending = value == 'City Ascending';
              } else if (value == 'Age') {
                _sortCriteria = 'Age';
                _isAscending = true;
              }
              _sortUsers();
            },
            itemBuilder: (context) => [
              _buildPopupMenuItem('Name Ascending', 'Sort by Name (A-Z)', Icons.arrow_upward),
              _buildPopupMenuItem('Name Descending', 'Sort by Name (Z-A)', Icons.arrow_downward),
              _buildPopupMenuItem('Age', 'Sort by Age', Icons.calendar_today),
              _buildPopupMenuItem('City Ascending', 'Sort by City (A-Z)', Icons.location_city),
              _buildPopupMenuItem('City Descending', 'Sort by City (Z-A)', Icons.location_city),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: SizedBox(height: 4,)
      )
          : _buildUserList(filteredUsers),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProfileScreen(),
            ),
          ).then((_) => _fetchUsers());
        },
        backgroundColor: const Color(0xFFFF5A8C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, String text, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF5A8C), size: 18),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> users) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 60,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? "No users available"
                  : "No users match your search",
              style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.8)),
            ),
            if (searchQuery.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    searchQuery = "";
                  });
                },
                child: const Text(
                  "Clear Search",
                  style: TextStyle(color: Color(0xFFFF5A8C), fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchUsers,
      color: const Color(0xFFFF5A8C),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 80),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Hero(
      tag: 'user_card_${user[ID]}',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 3,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: () => _viewUserDetails(user[ID]),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: user[GENDER] == "Male"
                              ? Colors.blue.withOpacity(0.5)
                              : Colors.pink.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: (user['profile_image'] != null && user['profile_image'].toString().isNotEmpty)
                            ? FileImage(File(user['profile_image']))
                            : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${user[FNAME]} ${user[LNAME]}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Icon(
                              //   user[GENDER] == "Male" ? Icons.male : Icons.female,
                              //   size: 18,
                              //   color: user[GENDER] == "Male" ? Colors.blue : const Color(0xFFFF5A8C),
                              // ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: user[GENDER] == "Male" ? Colors.blue.shade100 : Colors.pink.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  user[GENDER] == "Male" ? Icons.male : Icons.female,
                                  size: 14,
                                  color: user[GENDER] == "Male" ? Colors.blue : Colors.pink,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  user[GENDER],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: user[GENDER] == "Male" ? Colors.blue : Colors.pink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  user[CITY],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            user[FAV] == 1 ? Icons.favorite : Icons.favorite_border,
                            color: user[FAV] == 1 ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => _toggleFavorite(user[ID], user[FAV]),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: "view",
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, color: Colors.blue.shade700, size: 18),
                                  const SizedBox(width: 8),
                                  const Text("View Details"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: "edit",
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.green.shade700, size: 18),
                                  const SizedBox(width: 8),
                                  const Text("Edit User"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: "delete",
                              child: Row(
                                children: [
                                  const Icon(Icons.delete, color: Colors.red, size: 18),
                                  const SizedBox(width: 8),
                                  const Text("Delete User"),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == "view") {
                              _viewUserDetails(user[ID]);
                            } else if (value == "edit") {
                              _editUser(user);
                            } else if (value == "delete") {
                              _deleteUser(user[ID]);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.phone, color: Colors.green, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              user[NUMBER],
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.email, color: Colors.red, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              user[EMAIL],
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}