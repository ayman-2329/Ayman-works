// lib/screens/progress_tracker_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressTrackerScreen extends StatelessWidget {
  const ProgressTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Center(child: Text('Please log in to view your progress'));
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('progress')
                  .doc(user.uid)
                  .collection('aptitude')
                  .snapshots(),
              builder: (context, aptitudeSnapshot) {
                int totalAptitude = 0;
                int correctAptitude = 0;
                if (aptitudeSnapshot.hasData && aptitudeSnapshot.data != null) {
                  totalAptitude = aptitudeSnapshot.data!.docs.length;
                  for (var doc in aptitudeSnapshot.data!.docs) {
                    var data = doc.data() as Map<String, dynamic>;
                    if (data['isCorrect'] == true) {
                      correctAptitude++;
                    }
                  }
                }
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('progress')
                      .doc(user.uid)
                      .collection('logical')
                      .snapshots(),
                  builder: (context, logicalSnapshot) {
                    int totalLogical = 0;
                    int correctLogical = 0;
                    if (logicalSnapshot.hasData) {
                      totalLogical = logicalSnapshot.data!.docs.length;
                      for (var doc in logicalSnapshot.data!.docs) {
                        var data = doc.data() as Map<String, dynamic>;
                        if (data['isCorrect'] == true) {
                          correctLogical++;
                        }
                      }
                    }
                    // Dummy values for courses, replace with actual logic if needed
                    int completedCourses = 2;
                    int totalCourses = 5;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              'Courses',
                              '$completedCourses/$totalCourses',
                              Icons.book,
                              Colors.blue,
                            ),
                            _buildStatCard(
                              'Aptitude',
                              '$correctAptitude/$totalAptitude',
                              Icons.psychology,
                              Colors.green,
                            ),
                            _buildStatCard(
                              'Logical',
                              '$correctLogical/$totalLogical',
                              Icons.extension,
                              Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: completedCourses.toDouble(),
                                  title: 'Completed: $completedCourses',
                                  color: Colors.green,
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                PieChartSectionData(
                                  value: (totalCourses - completedCourses).toDouble(),
                                  title: 'Remaining: ${totalCourses - completedCourses}',
                                  color: Colors.grey,
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Weekly Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
                        const SizedBox(width: 8),
                        Text(
                          '5 Day Streak!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 150,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const style = TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  );
                                  switch (value.toInt()) {
                                    case 0:
                                      return const Text('Mon', style: style);
                                    case 1:
                                      return const Text('Tue', style: style);
                                    case 2:
                                      return const Text('Wed', style: style);
                                    case 3:
                                      return const Text('Thu', style: style);
                                    case 4:
                                      return const Text('Fri', style: style);
                                    case 5:
                                      return const Text('Sat', style: style);
                                    case 6:
                                      return const Text('Sun', style: style);
                                    default:
                                      return const Text('', style: style);
                                  }
                                },
                                reservedSize: 22,
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: 3,
                                  color: Colors.blue,
                                  width: 16,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: 2,
                                  color: Colors.blue,
                                  width: 16,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 2,
                              barRods: [
                                BarChartRodData(
                                  toY: 5,
                                  color: Colors.blue,
                                  width: 16,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 3,
                              barRods: [
                                BarChartRodData(
                                  toY: 4,
                                  color: Colors.blue,
                                  width: 16,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 4,
                              barRods: [
                                BarChartRodData(
                                  toY: 6,
                                  color: Colors.blue,
                                  width: 16,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 5,
                              barRods: [
                                BarChartRodData(
                                  toY: 2,
                                  color: Colors.blue,
                                  width: 16,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 6,
                              barRods: [
                                BarChartRodData(
                                  toY: 0,
                                  color: Colors.blue,
                                  width: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildLeaderboardItem(1, 'John Doe', 850, Colors.amber),
                    _buildLeaderboardItem(2, 'Jane Smith', 720, Colors.grey[300] ?? Colors.grey),
                    _buildLeaderboardItem(3, 'Bob Johnson', 680, Colors.brown[300] ?? Colors.brown),
                    const Divider(),
                    _buildLeaderboardItem(4, 'Alice Brown', 590, Colors.blue[100] ?? Colors.blue),
                    _buildLeaderboardItem(5, 'Charlie Davis', 520, Colors.blue[100] ?? Colors.blue),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildLeaderboardItem(int rank, String name, int score, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$score pts',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}