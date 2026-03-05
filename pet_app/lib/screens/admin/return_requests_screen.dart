/// Return Requests Screen
/// Users can request to return adopted pets, admins can process

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/health_provider.dart';
import '../../core/providers/auth_provider.dart';

class ReturnRequestsScreen extends StatefulWidget {
  const ReturnRequestsScreen({super.key});

  @override
  State<ReturnRequestsScreen> createState() => _ReturnRequestsScreenState();
}

class _ReturnRequestsScreenState extends State<ReturnRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  Future<void> _loadRequests() async {
    await Provider.of<HealthProvider>(context, listen: false).fetchReturnRequests();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.user?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Return Requests' : 'My Return Requests'),
        backgroundColor: AppColors.accentAmber,
      ),
      body: Consumer<HealthProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.returnRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_return, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No return requests',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadRequests,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.returnRequests.length,
              itemBuilder: (context, index) {
                return _buildRequestCard(provider.returnRequests[index], provider, isAdmin);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(request, HealthProvider provider, bool isAdmin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.accentAmber.withOpacity(0.1),
                  child: const Icon(Icons.pets, color: AppColors.accentAmber),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.petName ?? 'Unknown Pet',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (isAdmin && request.userName != null)
                        Text(
                          'From: ${request.userName}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                _buildStatusBadge(request.status),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Submitted Date
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Submitted: ${request.createdAt != null ? DateFormat('MMM d, yyyy').format(request.createdAt!) : 'N/A'}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Reason
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reason for Return',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(request.reason),
                ],
              ),
            ),
            
            // Admin Notes
            if (request.adminNotes != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Notes',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(request.adminNotes!),
                  ],
                ),
              ),
            ],
            
            // Admin Actions
            if (isAdmin && request.status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(request, provider),
                      icon: const Icon(Icons.close, color: AppColors.criticalRed),
                      label: const Text(
                        'Reject',
                        style: TextStyle(color: AppColors.criticalRed),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.criticalRed),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveRequest(request, provider),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = AppColors.primaryGreen;
        break;
      case 'rejected':
        color = AppColors.criticalRed;
        break;
      default:
        color = AppColors.accentAmber;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Future<void> _approveRequest(request, HealthProvider provider) async {
    final success = await provider.processReturnRequest(request.id, 'approved', null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Return approved' : 'Failed to approve'),
          backgroundColor: success ? AppColors.primaryGreen : AppColors.criticalRed,
        ),
      );
    }
  }

  void _showRejectDialog(request, HealthProvider provider) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Return Request'),
        content: TextField(
          controller: notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Admin Notes',
            hintText: 'Explain why this return is rejected...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.criticalRed),
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.processReturnRequest(
                request.id,
                'rejected',
                notesController.text,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Return rejected' : 'Failed to reject'),
                    backgroundColor: success ? AppColors.accentAmber : AppColors.criticalRed,
                  ),
                );
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
