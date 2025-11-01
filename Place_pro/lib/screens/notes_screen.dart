// lib/screens/notes_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No notes available'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var note = snapshot.data!.docs[index];
            var noteData = note.data() as Map<String, dynamic>;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                  size: 32,
                ),
                title: Text(
                  noteData['title'] ?? 'Note Title',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Category: ${noteData['category'] ?? 'N/A'}',
                ),
                trailing: const Icon(Icons.download),
                onTap: () async {
                  if (!context.mounted) return;

                  String? pdfUrl = noteData['pdf_url'];
                  if (pdfUrl != null && pdfUrl.isNotEmpty) {
                    // Download and open the PDF
                    try {
                      // First try to launch the URL directly
                      final uri = Uri.parse(pdfUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        // If that fails, download and open locally
                        final dir = await getApplicationDocumentsDirectory();
                        final file = File('${dir.path}/${noteData['title']}.pdf');
                        
                        if (!await file.exists()) {
                          final response = await http.get(Uri.parse(pdfUrl));
                          await file.writeAsBytes(response.bodyBytes);
                        }
                        
                        await OpenFilex.open(file.path);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error opening PDF: $e')),
                        );
                      }
                    }
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}