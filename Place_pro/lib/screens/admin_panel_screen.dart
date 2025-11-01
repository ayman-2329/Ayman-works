import 'package:flutter/material.dart';
import 'package:placepro/screens/admin/drives_management_screens.dart';
import 'package:placepro/screens/admin/courses_management_screen.dart';
import 'package:placepro/screens/admin/aplitude_management_screen.dart';
import 'package:placepro/screens/admin/logical_management_screen.dart';
import 'package:placepro/screens/admin/calender_management_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildAdminCard(
              context,
              'Manage Courses',
              Icons.book,
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CoursesManagementScreen(),
                  ),
                );
              },
            ),
            _buildAdminCard(
              context,
              'Manage Drives',
              Icons.business_center,
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DrivesManagementScreen(),
                  ),
                );
              },
            ),
            _buildAdminCard(
              context,
              'Aptitude Questions',
              Icons.psychology,
              Colors.orange,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AptitudeManagementScreen(),
                  ),
                );
              },
            ),
            _buildAdminCard(
              context,
              'Logical Problems',
              Icons.extension,
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LogicalManagementScreen(),
                  ),
                );
              },
            ),
            _buildAdminCard(
              context,
              'Calendar Events',
              Icons.calendar_today,
              Colors.red,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalendarManagementScreen(),
                  ),
                );
              },
            ),
            _buildAdminCard(
              context,
              'Student Progress',
              Icons.assessment,
              Colors.teal,
              () {
                // Navigate to student progress screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}