// lib/screens/resume_builder_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  ResumeBuilderScreenState createState() => ResumeBuilderScreenState();
}

class ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _skillsController = TextEditingController();
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _projectsController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _skillsController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    _projectsController.dispose();
    super.dispose();
  }

  Future<void> _generateResume() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final pdf = pw.Document();

        // Add a page to the PDF
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header with name and contact info
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        _nameController.text,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(_emailController.text),
                      pw.Text(_phoneController.text),
                    ],
                  ),

                  pw.SizedBox(height: 24),

                  // Skills section
                  pw.Text(
                    'Skills',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(_skillsController.text),

                  pw.SizedBox(height: 16),

                  // Education section
                  pw.Text(
                    'Education',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(_educationController.text),

                  pw.SizedBox(height: 16),

                  // Experience section
                  pw.Text(
                    'Experience',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(_experienceController.text),

                  pw.SizedBox(height: 16),

                  // Projects section
                  pw.Text(
                    'Projects',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(_projectsController.text),
                ],
              );
            },
          ),
        );

        // Save the PDF to a file
        final output = await getTemporaryDirectory();
        final file = File('${output.path}/resume.pdf');
        final pdfBytes = await pdf.save();
        await file.writeAsBytes(pdfBytes);

        // Upload to Firebase Storage
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('resumes')
              .child('${user.uid}.pdf');

          await storageRef.putFile(file);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resume saved successfully!')),
          );
        }

        // Open the PDF for preview
        if (!mounted) return;
        await Printing.sharePdf(bytes: pdfBytes, filename: 'resume.pdf');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating resume: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Builder'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _skillsController,
                      decoration: const InputDecoration(
                        labelText: 'Skills',
                        border: OutlineInputBorder(),
                        hintText: 'List your technical and soft skills',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your skills';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _educationController,
                      decoration: const InputDecoration(
                        labelText: 'Education',
                        border: OutlineInputBorder(),
                        hintText: 'Degrees, institutions, graduation years',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your education details';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _experienceController,
                      decoration: const InputDecoration(
                        labelText: 'Work Experience (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Companies, positions, durations',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _projectsController,
                      decoration: const InputDecoration(
                        labelText: 'Projects (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Project titles, descriptions, technologies used',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: _generateResume,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Generate Resume'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}