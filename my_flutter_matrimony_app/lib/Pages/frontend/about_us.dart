import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeamPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFFFF4081),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(vertical: 24),
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    'Darshan Matrimony',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Connecting Hearts Since 2023',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Divider(),

            // Team Section
            _buildSectionTitle('Meet Our Team'),
            SizedBox(height: 16),
            _buildTeamMemberCard(
              name: 'Nandan Lalani',
              role: 'Lead Developer',
              id: '23010101150',
            ),
            SizedBox(height: 24),

            // Mentor Section
            _buildSectionTitle('Guided By'),
            SizedBox(height: 16),
            _buildSimpleCard(
              title: 'Prof. Mehul Bhundiya',
              subtitle: 'Computer Engineering Department',
              description: 'School of Computer Science',
              icon: Icons.school,
            ),
            SizedBox(height: 24),

            // Info Section
            _buildSectionTitle('Affiliations'),
            SizedBox(height: 16),
            _buildSimpleCard(
              title: 'ASWDC',
              subtitle: 'Explored by',
              description: 'Application, Software, and Website Development Center',
              icon: Icons.code,
            ),
            SizedBox(height: 16),
            _buildSimpleCard(
              title: 'Darshan University',
              subtitle: 'Eulogized by',
              description: 'Rajkot, Gujarat - INDIA',
              icon: Icons.school,
            ),
            SizedBox(height: 24),

            // Contact Section
            _buildSectionTitle('Get in Touch'),
            SizedBox(height: 16),
            _buildContactInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildTeamMemberCard({
    required String name,
    required String role,
    required String id,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.pink.shade100,
              child: Icon(
                Icons.person,
                size: 30,
                color: Color(0xFFFF4081),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    role,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Color(0xFFFF4081),
                    ),
                  ),
                  Text(
                    'ID: $id',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Color(0xFFFF4081),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      elevation: 2,
      color: Color(0xFFFF4081),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.email_outlined, color: Colors.white, size: 18),
                SizedBox(width: 12),
                Text(
                  'contact@darshanmatrimony.edu.in',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
                SizedBox(width: 12),
                Text(
                  'Darshan University, Rajkot, Gujarat',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.facebook, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.email, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.language, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}