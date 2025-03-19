import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterproject/string_const.dart';
import '../backend/Database.dart';
import 'add_profile_screen.dart';
import 'user_detail_screen.dart';

class FavoriteUserScreen extends StatefulWidget {
  @override
  _FavoriteUserScreenState createState() => _FavoriteUserScreenState();
}

class _FavoriteUserScreenState extends State<FavoriteUserScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _favoriteUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteUsers();
  }

  Future<void> _fetchFavoriteUsers() async {
    setState(() {
      _isLoading = true;
    });

    final allUsers = await _apiService.fetchUsers(context);

    setState(() {
      _favoriteUsers = allUsers.where((user) => user[FAV] == 1).toList();
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(String userId, int currentStatus) async {
    await _apiService.updateUser(context, userId, {FAV: currentStatus == 1 ? 0 : 1});
    _fetchFavoriteUsers();
  }

  Future<void> _deleteUser(String userId) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete) {
      await _apiService.deleteUser(context, userId);
      _fetchFavoriteUsers();
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Delete"),
          ),
        ],
      ),
    ) ?? false;
  }

  void _editUser(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProfileScreen(userData: user, userId: user[ID]),
      ),
    ).then((_) => _fetchFavoriteUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Favorite Users",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchFavoriteUsers,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? Center(
          child: SizedBox(height: 4,)
        )
            : _favoriteUsers.isEmpty
            ? _buildEmptyState()
            : _buildUserList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.pink.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            "No favorite users yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Add users to favorites to see them here",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _favoriteUsers.length,
      itemBuilder: (context, index) {
        final user = _favoriteUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.pink.withOpacity(0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailScreen(userId: user[ID]),
            ),
          ).then((_) => _fetchFavoriteUsers());
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'profile_${user[ID]}',
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: (user['profile_image'] != null && user['profile_image'].toString().isNotEmpty)
                              ? FileImage(File(user['profile_image']))
                              : AssetImage('assets/images/default_profile.png') as ImageProvider,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "${user[FNAME]} ${user[LNAME]}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
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
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.orange, size: 16),
                            SizedBox(width: 4),
                            Text(
                              user[CITY],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.favorite, color: Colors.pink, size: 26),
                        onPressed: () => _toggleFavorite(user[ID], user[FAV]),
                        tooltip: 'Remove from favorites',
                      ),
                      PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) {
                          if (value == "edit") {
                            _editUser(user);
                          } else if (value == "delete") {
                            _deleteUser(user[ID]);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: "edit",
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue, size: 18),
                                SizedBox(width: 8),
                                Text("Edit Profile"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: "delete",
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text("Delete User"),
                              ],
                            ),
                          ),
                        ],
                        icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Divider(thickness: 1, color: Colors.grey.shade200),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.phone, color: Colors.green, size: 18),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            user[NUMBER],
                            style: TextStyle(fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.email, color: Colors.red, size: 18),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            user[EMAIL],
                            style: TextStyle(fontSize: 15),
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
    );
  }
}