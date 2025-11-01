// lib/screens/admin/drives_management_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DrivesManagementScreen extends StatefulWidget {
  const DrivesManagementScreen({super.key});

  @override
  DrivesManagementScreenState createState() => DrivesManagementScreenState();
}

class DrivesManagementScreenState extends State<DrivesManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _applyLinkController = TextEditingController();
  DateTime? _selectedDeadline;
  bool _isLoading = false;
  bool _isAdding = false;

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _deadlineController.dispose();
    _applyLinkController.dispose();
    super.dispose();
  }

  // Helper method to get company logo widget
  Widget _getCompanyLogo(String companyName) {
    final defaultIcon = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.business,
        size: 30,
        color: Colors.blue[700],
      ),
    );

    if (companyName.isEmpty) return defaultIcon;

    // Try loading from assets
    final basePath = 'assets/images/companies/${companyName.toLowerCase().replaceAll(' ', '_')}';
    
    // First try with .jpg
    final jpgPath = '$basePath.jpg';
    
    return Image.asset(
      jpgPath,
      width: 50,
      height: 50,
      errorBuilder: (context, error, stackTrace) {
        // If .jpg fails, try .png
        final pngPath = '$basePath.png';
        return Image.asset(
          pngPath,
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) {
            // If both fail, return default icon
            return defaultIcon;
          },
        );
      },
    );
  }

  // Helper method to launch URLs
  Future<void> _launchURL(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && mounted) {
      setState(() {
        _selectedDeadline = picked;
        _deadlineController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _addDrive() async {
    if (_formKey.currentState!.validate() && _selectedDeadline != null) {
      setState(() {
        _isLoading = true;
      });
      
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        await FirebaseFirestore.instance.collection('drives').add({
          'company': _companyController.text.trim(),
          'role': _roleController.text.trim(),
          'deadline': Timestamp.fromDate(_selectedDeadline!),
          'apply_link': _applyLinkController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        _clearForm();
        setState(() {
          _isAdding = false;
        });
        
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Drive added successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error adding drive: $e')),
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

  void _clearForm() {
    _companyController.clear();
    _roleController.clear();
    _deadlineController.clear();
    _applyLinkController.clear();
    _selectedDeadline = null;
  }

  Future<void> _deleteDrive(String driveId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Drive'),
        content: const Text('Are you sure you want to delete this drive?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              setState(() {
                _isLoading = true;
              });

              try {
                await FirebaseFirestore.instance
                    .collection('drives')
                    .doc(driveId)
                    .delete();

                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Drive deleted successfully')),
                  );
                }
                nav.pop(); // Pop after the operation is complete
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error deleting drive: $e')),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Drives'),
        actions: [
          IconButton(
            icon: Icon(_isAdding ? Icons.cancel : Icons.add),
            onPressed: () {
              setState(() {
                _isAdding = !_isAdding;
                if (!_isAdding) {
                  _clearForm();
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_isAdding) _buildAddDriveForm(),
                const Divider(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('drives')
                        .orderBy('deadline')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No drives available'));
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var drive = snapshot.data!.docs[index];
                          var driveData = drive.data() as Map<String, dynamic>;
                          String driveId = drive.id;
                          
                          DateTime deadline = (driveData['deadline'] as Timestamp).toDate();
                          bool isExpired = deadline.isBefore(DateTime.now());
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: _getCompanyLogo(driveData['company'] ?? ''),
                              title: Text(
                                driveData['company'] ?? 'Company Name',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (driveData['role'] != null)
                                    Text(
                                      driveData['role'],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('MMM dd, yyyy').format(deadline),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isExpired ? Colors.red : Colors.grey[700],
                                          fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (driveData['apply_link'] != null &&
                                      driveData['apply_link'].toString().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: InkWell(
                                        onTap: () => _launchURL(driveData['apply_link']),
                                        child: const Text(
                                          'Apply Now →',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteDrive(driveId),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAddDriveForm() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add New Drive',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deadlineController,
                decoration: const InputDecoration(
                  labelText: 'Deadline',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDeadline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select deadline';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _applyLinkController,
                decoration: const InputDecoration(
                  labelText: 'Apply Link',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter apply link';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addDrive,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add Drive'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}