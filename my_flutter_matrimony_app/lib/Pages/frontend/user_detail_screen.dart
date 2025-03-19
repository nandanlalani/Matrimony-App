import 'dart:io';
import 'package:flutter/material.dart';
import '../../string_const.dart';
import '../backend/Database.dart';
import 'add_profile_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;

  const UserDetailScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final user = await _apiService.fetchUserById(context, widget.userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching user details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load user data'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showHobbiesDialog() {
    final hobbies = _user?['hobbies'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Hobbies",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF5A8C),
              fontSize: 22,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 300),
            child: hobbies.isEmpty
                ? const Center(
              child: Text(
                "No hobbies available",
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: hobbies.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.star, color: Color(0xFFFF5A8C)),
                  title: Text(
                    hobbies[index].toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5A8C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text("Close"),
            ),
          ],
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          buttonPadding: const EdgeInsets.all(15),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          _user?['user_firstName'] ?? "User Profile",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFFF5A8C),
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProfileScreen(userData: _user, userId: _user?[ID]),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: SizedBox(height: 4,)
      )
          : _user == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              "User data not available",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _fetchUserDetails();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5A8C),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildContactCard(),
            const SizedBox(height: 16),
            _buildPersonalCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      width: 350,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Hero(
            tag: 'profile_${widget.userId}',
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF5A8C), width: 3),
              ),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey[200],
                backgroundImage: (_user!['profile_image'] != null && _user!['profile_image'].toString().isNotEmpty)
                    ? FileImage(File(_user!['profile_image']))
                    : const AssetImage('assets/images/default_profile.png') as ImageProvider,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "${_user!['user_firstName'] ?? ''} ${_user!['user_lastName'] ?? ''}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "@${_user!['user_Name'] ?? ''}",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return _buildCard(
      title: "Basic Information",
      icon: Icons.person_outline,
      children: [
        _buildInfoRow(Icons.badge, "First Name", _user!["user_firstName"] ?? "N/A"),
        _buildInfoRow(Icons.family_restroom, "Last Name", _user!["user_lastName"] ?? "N/A"),
        _buildInfoRow(Icons.calendar_today, "Date of Birth", _user!["dob"] ?? "N/A"),
        _buildInfoRow(Icons.wc, "Gender", _user!["gender"] ?? "N/A"),
      ],
    );
  }

  Widget _buildContactCard() {
    return _buildCard(
      title: "Contact Information",
      icon: Icons.contact_phone_outlined,
      children: [
        _buildInfoRow(Icons.email, "Email", _user!["user_email"] ?? "N/A"),
        _buildInfoRow(Icons.phone, "Mobile", _user!["user_number"] ?? "N/A"),
        _buildInfoRow(Icons.location_on, "City", _user!["city"] ?? "N/A"),
      ],
    );
  }

  Widget _buildPersonalCard() {
    final hobbies = _user?['hobbies'] as List<dynamic>? ?? [];

    return _buildCard(
      title: "Personal Interests",
      icon: Icons.favorite_border,
      children: [
        InkWell(
          onTap: hobbies.isNotEmpty ? _showHobbiesDialog : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.sports_esports, color: Color(0xFFFF5A8C), size: 22),
                const SizedBox(width: 12),
                const Text(
                  "Hobbies:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: hobbies.isNotEmpty
                      ? Text(
                    hobbies.join(", "),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                      : const Text(
                    "No hobbies added",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF999999),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                if (hobbies.isNotEmpty)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFFBBBBBB),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFFF5A8C), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFF5A8C), size: 22),
          const SizedBox(width: 12),
          Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }
}