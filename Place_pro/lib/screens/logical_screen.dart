// lib/screens/logical_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:placepro/screens/logical_puzzle_screen.dart';

class LogicalScreen extends StatefulWidget {
    const LogicalScreen({super.key});

  @override
  LogicalScreenState createState() => LogicalScreenState();
}

class LogicalScreenState extends State<LogicalScreen> {
  final List<String> categories = ['Puzzles', 'Pattern Problems', 'Venn Diagrams'];
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category Tabs
        Container(
          color: Colors.blue[50],
          child: Row(
            children: List.generate(
              categories.length,
              (index) => Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _selectedCategoryIndex == index
                          ? Colors.blue
                          : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      categories[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedCategoryIndex == index
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Problems List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('logical')
                .doc(categories[_selectedCategoryIndex].toLowerCase().replaceAll(' ', '_'))
                .collection('problems')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No problems available'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var problem = snapshot.data!.docs[index];
                  var problemData = problem.data() as Map<String, dynamic>;
                  String problemId = problem.id;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        'Problem ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        problemData['title'] ?? 'Problem title',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogicalPuzzleScreen(
                              category: categories[_selectedCategoryIndex],
                              problemId: problemId,
                              problemData: problemData,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}