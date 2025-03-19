import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../string_const.dart';
import 'backend/Database.dart';
import 'frontend/about_us.dart';
import 'frontend/add_profile_screen.dart';
import 'frontend/favorite_users_screen_state.dart';
import 'frontend/login_page.dart';
import 'frontend/user_list_screen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, RouteAware {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _favoriteUsers = [];
  bool _isLoadingUsers = true;
  bool _isLoadingFavorites = true;
  final List<String> _greetings = [
    "Find your perfect match",
    "Discover your soulmate",
    "Begin your journey",
    "Connect with hearts"
  ];
  int _selectedIndex = 0;
  // Track if a logout dialog is currently showing to prevent duplicates
  bool _isShowingLogoutDialog = false;

  // Add this flag to track initialization
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to handle initialization after the first render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  // Move initialization logic to a separate method
  Future<void> _initialize() async {
    await _checkLoginStatus();
    if (mounted) {
      await _fetchData();
      // Mark as initialized after data is loaded
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // This is called when returning to this screen from another screen
    super.didPopNext();
    // Refresh data immediately when returning to this screen
    _fetchData();
  }

  // Main function to fetch all required data
  Future<void> _fetchData() async {
    // Use Future.wait to run both fetch operations in parallel
    await Future.wait([
      _fetchFavoriteUsers(),
    ]);
  }

  Future<void> _fetchFavoriteUsers() async {
    setState(() {
      _isLoadingUsers = true;
      _isLoadingFavorites = true; // Add this line to ensure both loading states are set
    });

    final allUsers = await _apiService.fetchUsers(context);

    if (mounted) {
      setState(() {
        _users = allUsers;
        _favoriteUsers = allUsers.where((user) => user[FAV] == 1).toList();
        _isLoadingUsers = false;
        _isLoadingFavorites = false; // Add this line to update the loading state
      });
    }
  }


  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (!isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    // Prevent multiple dialogs from showing at once
    if (_isShowingLogoutDialog) return;

    setState(() {
      _isShowingLogoutDialog = true;
    });

    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Use a unique key for this dialog
        return AlertDialog(
          key: UniqueKey(), // Add this line to ensure a unique key
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFFF4C94)),
              SizedBox(width: 8),
              Text("Logout",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
                  )
              ),
            ],
          ),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  _isShowingLogoutDialog = false;
                });
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("Cancel",
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600
                  )
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pop(dialogContext);
                setState(() {
                  _isShowingLogoutDialog = false;
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF4C94),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ).then((_) {
      // Ensure flag is reset even if dialog is dismissed unexpectedly
      if (mounted) {
        setState(() {
          _isShowingLogoutDialog = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while initializing
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4C94)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false, // Don't apply SafeArea padding at bottom
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // Change from BouncingScrollPhysics
                  padding: const EdgeInsets.only(bottom: 80), // Extra padding for FAB space
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildStatistics(),
                      _buildMenuGrid(),
                      // Add additional bottom padding specifically to solve overflow
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Move FAB to a specific location that doesn't interfere
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 16), // Add padding to the FAB
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddProfileScreen()),
            ).then((_) {
              // Refresh data when returning from AddProfileScreen
              _fetchData();
            });
          },
          backgroundColor: Color(0xFFFF4C94),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // Set this to ensure proper resizing around FAB
      resizeToAvoidBottomInset: true,
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF4C94), Color(0xFFF36EB1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "DM",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Darshan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          Row(
            children: [
              InkWell(
                onTap: () => _logout(context),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.logout_outlined, color: Color(0xFF666666), size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Find Your",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              Row(
                children: [
                  Text(
                    "Perfect ",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    "Match",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF4C94),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                _greetings[_selectedIndex % _greetings.length],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF3F7), Color(0xFFFFF7F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              Icons.group,
              _isLoadingUsers ? "..." : _users.length.toString(),
              "Total Users"
          ),
          _buildDivider(),
          _buildStatItem(
              Icons.favorite,
              _isLoadingFavorites ? "..." : _favoriteUsers.length.toString(),
              "Favourite Users"
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.pink.withOpacity(0.1),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFFFF4C94), size: 22),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 30), // Increased bottom padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Access",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            padding: EdgeInsets.zero, // Ensure no internal padding
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              MenuCard(
                key: UniqueKey(), // Add unique key
                icon: Icons.person_add,
                title: "Add Profile",
                description: "Create a new profile",
                color: Color(0xFFE3F2FD),
                textColor: Color(0xFF1976D2),
                iconColor: Color(0xFF1976D2),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProfileScreen()),
                ).then((_) {
                  // Refresh data when returning from AddProfileScreen
                  _fetchData();
                }),
              ),
              MenuCard(
                key: UniqueKey(), // Add unique key
                icon: Icons.search,
                title: "Browse Profiles",
                description: "Find your match",
                color: Color(0xFFE8F5E9),
                textColor: Color(0xFF388E3C),
                iconColor: Color(0xFF388E3C),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserListScreen()),
                ).then((_) {
                  // Refresh data when returning from UserListScreen
                  _fetchData();
                }),
              ),
              MenuCard(
                key: UniqueKey(), // Add unique key
                icon: Icons.favorite,
                title: "Favorites",
                description: "View saved profiles",
                color: Color(0xFFFCE4EC),
                textColor: Color(0xFFE91E63),
                iconColor: Color(0xFFE91E63),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoriteUserScreen()),
                ).then((_) {
                  // Refresh data when returning from FavoriteUserScreen
                  _fetchData();
                }),
              ),
              MenuCard(
                key: UniqueKey(), // Add unique key
                icon: Icons.info_outline,
                title: "About Us",
                description: "Our team & mission",
                color: Color(0xFFEDE7F6),
                textColor: Color(0xFF673AB7),
                iconColor: Color(0xFF673AB7),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeamPage()),
                ).then((_) {
                  // Refresh data when returning from TeamPage
                  _fetchData();
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onTap;

  MenuCard({
    Key? key, // Accept optional key parameter
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.textColor,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key); // Pass key to super constructor

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: iconColor),
            SizedBox(height: 3),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}