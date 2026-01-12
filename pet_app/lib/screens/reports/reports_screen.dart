/// Reports Screen
/// Generate and download various reports in PDF/CSV formats

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.user?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: AppColors.secondaryBlue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Report Types Header
          Text(
            'Available Reports',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Generate detailed reports in PDF or CSV format',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Adoption Reports
          _buildReportCard(
            icon: Icons.favorite,
            title: 'Adoption Report',
            description: 'Summary of all adoption requests and their statuses',
            color: AppColors.primaryGreen,
            reportType: 'adoptions',
          ),
          
          // Pet Inventory
          if (isAdmin)
            _buildReportCard(
              icon: Icons.pets,
              title: 'Pet Inventory Report',
              description: 'Complete list of all registered pets with status breakdown',
              color: AppColors.secondaryBlue,
              reportType: 'inventory',
            ),
          
          // Vaccination Schedule
          _buildReportCard(
            icon: Icons.vaccines,
            title: 'Vaccination Report',
            description: 'Upcoming and overdue vaccinations for all pets',
            color: AppColors.accentAmber,
            reportType: 'vaccinations',
          ),
          
          // User Report (Admin only)
          if (isAdmin)
            _buildReportCard(
              icon: Icons.people,
              title: 'User Report',
              description: 'List of all registered users and their activity',
              color: Colors.purple,
              reportType: 'users',
            ),
          
          // Category Report
          if (isAdmin)
            _buildReportCard(
              icon: Icons.category,
              title: 'Category Statistics',
              description: 'Pet distribution across categories with adoption rates',
              color: Colors.teal,
              reportType: 'categories',
            ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required String reportType,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isGenerating ? null : () => _generateReport(reportType, 'csv'),
                    icon: const Icon(Icons.table_chart),
                    label: const Text('CSV'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : () => _generateReport(reportType, 'pdf'),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateReport(String reportType, String format) async {
    setState(() => _isGenerating = true);

    // Simulate report generation
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isGenerating = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(
            Icons.check_circle,
            color: AppColors.primaryGreen,
            size: 48,
          ),
          title: const Text('Report Generated'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your ${reportType.toUpperCase()} report has been generated in ${format.toUpperCase()} format.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      format == 'pdf' ? Icons.picture_as_pdf : Icons.table_chart,
                      color: format == 'pdf' ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${reportType}_report.${format}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Downloading ${reportType}_report.${format}...'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Download'),
            ),
          ],
        ),
      );
    }
  }
}
