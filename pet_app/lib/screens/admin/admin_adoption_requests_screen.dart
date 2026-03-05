/// Admin Adoption Requests Screen
/// Allows admins to view and process adoption requests

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/adoption_provider.dart';
import '../../core/utils/category_utils.dart';

class AdminAdoptionRequestsScreen extends StatefulWidget {
  const AdminAdoptionRequestsScreen({super.key});

  @override
  State<AdminAdoptionRequestsScreen> createState() => _AdminAdoptionRequestsScreenState();
}

class _AdminAdoptionRequestsScreenState extends State<AdminAdoptionRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    await Provider.of<AdoptionProvider>(context, listen: false).fetchAllRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adoption Requests'),
        backgroundColor: AppColors.secondaryBlue,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: Consumer<AdoptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRequestList(
                provider.allRequests.where((r) => r.status == 'pending').toList(),
                'pending',
                provider,
              ),
              _buildRequestList(
                provider.allRequests.where((r) => r.status == 'approved').toList(),
                'approved',
                provider,
              ),
              _buildRequestList(
                provider.allRequests.where((r) => r.status == 'rejected').toList(),
                'rejected',
                provider,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestList(List requests, String status, AdoptionProvider provider) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'pending' 
                  ? Icons.pending_actions
                  : status == 'approved' 
                      ? Icons.check_circle 
                      : Icons.cancel,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No $status requests',
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
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestCard(request, provider);
        },
      ),
    );
  }

  Widget _buildRequestCard(request, AdoptionProvider provider) {
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
                  backgroundColor: AppColors.secondaryBlue.withOpacity(0.1),
                  child: const Icon(Icons.pets, color: AppColors.secondaryBlue),
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
                      Text(
                        'Requested by ${request.userName ?? 'Unknown'}',
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
            
            const SizedBox(height: 16),
            
            // Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    Icons.email,
                    'Email',
                    request.userEmail ?? 'N/A',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Requested',
                    request.createdAt != null
                        ? DateFormat('MMM d, yyyy').format(request.createdAt!)
                        : 'N/A',
                  ),
                  if (request.compatibilityScore != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.auto_awesome,
                      'AI Match Score',
                      '${request.compatibilityScore}%',
                      valueColor: AppColors.secondaryBlue,
                    ),
                  ],
                ],
              ),
            ),
            
            // Message
            if (request.requestMessage != null && request.requestMessage!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Message:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                request.requestMessage!,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            
            // Actions for pending
            if (request.status == 'pending') ...[
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
            
            // Rejection reason
            if (request.status == 'rejected' && request.rejectionReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.criticalRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: AppColors.criticalRed, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.rejectionReason!,
                        style: const TextStyle(color: AppColors.criticalRed),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: AppColors.getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Future<void> _approveRequest(request, AdoptionProvider provider) async {
    final success = await provider.processRequest(request.id, 'approved', null, null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Request approved!' : 'Failed to approve'),
          backgroundColor: success ? AppColors.primaryGreen : AppColors.criticalRed,
        ),
      );
    }
  }

  void _showRejectDialog(request, AdoptionProvider provider) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Rejection Reason',
            hintText: 'Explain why this request is rejected...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.criticalRed,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.processRequest(
                request.id,
                'rejected',
                null,
                reasonController.text,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Request rejected' : 'Failed to reject'),
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
