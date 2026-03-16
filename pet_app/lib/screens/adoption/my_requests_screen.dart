/// My Requests Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/adoption_provider.dart';
import 'package:intl/intl.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<AdoptionProvider>(context, listen: false).fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Adoption Requests'),
      ),
      body: Consumer<AdoptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No adoption requests yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchRequests(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.requests.length,
              itemBuilder: (context, index) {
                final request = provider.requests[index];
                return _buildRequestCard(request);
              },
            ),
          );
        },
      ),
    );
  }

  void _showReapplyDialog(request) {
    final messageController = TextEditingController(text: request.requestMessage ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Re-apply for ${request.petName ?? 'this pet'}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Update your message and re-submit your adoption request.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message (optional)',
                hintText: 'Tell us why you would be a great owner...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  final provider = Provider.of<AdoptionProvider>(context, listen: false);
                  final success = await provider.reapplyRequest(
                    request.id,
                    messageController.text.isEmpty ? null : messageController.text,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Reapplication submitted successfully!'
                            : 'Failed to reapply. Please try again.'),
                        backgroundColor:
                            success ? AppColors.primaryGreen : AppColors.criticalRed,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Submit Reapplication',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                  child: const Icon(Icons.pets, color: AppColors.primaryGreen),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.petName ?? 'Pet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Requested on ${DateFormat('MMM d, yyyy').format(request.createdAt ?? DateTime.now())}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(request.status),
              ],
            ),
            
            if (request.compatibilityScore != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: AppColors.secondaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Compatibility: ${request.compatibilityScore}%',
                    style: const TextStyle(
                      color: AppColors.secondaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            
            if (request.requestMessage != null && request.requestMessage!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Your message:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(request.requestMessage!),
            ],
            
            if (request.isRejected && request.rejectionReason != null) ...[
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
            if (request.isRejected) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showReapplyDialog(request),
                  icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
                  label: const Text(
                    'Re-apply',
                    style: TextStyle(color: AppColors.primaryGreen),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryGreen),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
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
          fontSize: 12,
        ),
      ),
    );
  }
}
