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
