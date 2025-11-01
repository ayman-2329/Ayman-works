// lib/screens/drives_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:placepro/data/recruiting_companies_data.dart';

class DrivesScreen extends StatelessWidget {
  const DrivesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recruiting Companies Section
          _buildRecruitingCompaniesSection(context),
          
          const SizedBox(height: 24),
          
          // Active Drives Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Active Drives',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Drives List
          _buildDrivesList(),
        ],
      ),
    );
  }

  Widget _buildRecruitingCompaniesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_center, color: Colors.blue[600], size: 28),
              const SizedBox(width: 12),
              Text(
                'Our Recruiting Partners',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Top companies that regularly recruit our students',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Company Logos Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: RecruitingCompaniesData.companies.length,
            itemBuilder: (context, index) {
              final company = RecruitingCompaniesData.companies[index];
              return _buildCompanyCard(context, company);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(BuildContext context, RecruitingCompany company) {
    // Shorten text if too long
    String industry = company.industry.length > 15 
        ? '${company.industry.substring(0, 15)}...' 
        : company.industry;
    
    String companyName = company.name.length > 15
        ? '${company.name.substring(0, 15)}...'
        : company.name;

    return Container(
      width: 120, // Reduced width
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _showCompanyDetails(context, company),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: company.primaryColor.withOpacity(0.05),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Company Logo with fixed size container
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: _buildCompanyLogo(company.logoPath),
                ),
                
                const SizedBox(height: 6),
                
                // Company Name
                Text(
                  companyName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 2),
                
                // Package - More compact
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: company.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹${(company.averagePackage / 1000).toStringAsFixed(0)}K',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: company.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCompanyDetails(BuildContext context, RecruitingCompany company) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: company.primaryColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: company.primaryColor.withAlpha(76),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              company.icon,
                              size: 48,
                              color: company.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  company.name,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  company.industry,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Company Description
                      Text(
                        'About',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        company.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Key Information
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              'Recruitment',
                              company.recruitmentFrequency,
                              Icons.schedule,
                              company.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              'Avg Package',
                              '₹${(company.averagePackage / 100000).toStringAsFixed(1)}L',
                              Icons.attach_money,
                              company.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Specializations
                      Text(
                        'Specializations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: company.specializations.map((spec) => 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: company.primaryColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: company.primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              spec,
                              style: TextStyle(
                                fontSize: 14,
                                color: company.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Visit Website Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(company.website);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Could not launch website')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: company.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.language),
                          label: const Text('Visit Website'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyLogo(String logoPath) {
    return Image.asset(
      logoPath,
      width: 50,
      height: 50,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading image: $error');
        return _buildFallbackIcon();
      },
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: 24,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 2),
          Text(
            'LOGO',
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrivesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('drives')
          .orderBy('deadline')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No active drives'));
        }
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var drive = snapshot.data!.docs[index];
            var driveData = drive.data() as Map<String, dynamic>;
            
            DateTime deadline = (driveData['deadline'] as Timestamp).toDate();
            bool isExpired = deadline.isBefore(DateTime.now());
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            driveData['company'] ?? 'Company Name',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isExpired ? Colors.red : Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isExpired ? 'Expired' : 'Active',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Role: ${driveData['role'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Deadline: ${DateFormat('dd MMM yyyy').format(deadline)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isExpired
                            ? null
                            : () async {
                                String? applyLink = driveData['apply_link'];
                                if (applyLink != null && applyLink.isNotEmpty) {
                                  final uri = Uri.parse(applyLink);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Could not launch URL')),
                                      );
                                    }
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Apply Now'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}