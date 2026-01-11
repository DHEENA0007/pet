/// Admin Dashboard Screen

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService().get(ApiConstants.adminDashboard);
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.secondaryBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _buildStatCard(
                          'Total Pets',
                          _stats?['total_pets']?.toString() ?? '0',
                          Icons.pets,
                          AppColors.primaryGreen,
                        ),
                        _buildStatCard(
                          'Available',
                          _stats?['available_pets']?.toString() ?? '0',
                          Icons.check_circle,
                          AppColors.secondaryBlue,
                        ),
                        _buildStatCard(
                          'Pending Approvals',
                          _stats?['pending_approvals']?.toString() ?? '0',
                          Icons.pending,
                          AppColors.accentAmber,
                          onTap: () => context.push('/admin/pending'),
                        ),
                        _buildStatCard(
                          'Pending Adoptions',
                          _stats?['pending_adoptions']?.toString() ?? '0',
                          Icons.favorite,
                          AppColors.criticalRed,
                        ),
                        _buildStatCard(
                          'Adopted',
                          _stats?['adopted_pets']?.toString() ?? '0',
                          Icons.home,
                          Colors.purple,
                        ),
                        _buildStatCard(
                          'Total Users',
                          _stats?['total_users']?.toString() ?? '0',
                          Icons.people,
                          Colors.teal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildActionCard(
                      icon: Icons.pending_actions,
                      title: 'Pending Pet Approvals',
                      subtitle: '${_stats?['pending_approvals'] ?? 0} pets waiting for review',
                      color: AppColors.accentAmber,
                      onTap: () => context.push('/admin/pending'),
                    ),
                    
                    _buildActionCard(
                      icon: Icons.assignment,
                      title: 'Adoption Requests',
                      subtitle: '${_stats?['pending_adoptions'] ?? 0} requests pending',
                      color: AppColors.secondaryBlue,
                      onTap: () {},
                    ),
                    
                    _buildActionCard(
                      icon: Icons.vaccines,
                      title: 'Vaccination Alerts',
                      subtitle: '${_stats?['upcoming_vaccinations'] ?? 0} due soon',
                      color: AppColors.criticalRed,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
