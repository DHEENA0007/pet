/// Help & Support Screen
/// FAQs, contact support, tutorials

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryGreen.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.help_center,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Find answers to common questions or get in touch with our support team.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // FAQ Section
            _buildSectionHeader('Frequently Asked Questions'),
            _buildHelpItem(
              icon: Icons.pets,
              title: 'How do I adopt a pet?',
              content: 'Browse available pets, view their details, and submit an adoption request. Our team will review your application and contact you.',
            ),
            _buildHelpItem(
              icon: Icons.assignment,
              title: 'How do I post a pet for adoption?',
              content: 'Use the "Post Pet" button to add your pet\'s details. Our admin team will review and approve your listing.',
            ),
            _buildHelpItem(
              icon: Icons.notifications,
              title: 'How do I get notified about updates?',
              content: 'Enable push notifications in settings. You\'ll receive updates about your adoption requests and pet care reminders.',
            ),
            _buildHelpItem(
              icon: Icons.vaccines,
              title: 'What about pet vaccinations?',
              content: 'Admins manage vaccination schedules. Adopted pet owners receive notifications about upcoming vaccinations.',
            ),

            const SizedBox(height: 32),

            // Contact Support Section
            _buildSectionHeader('Contact Support'),
            _buildContactItem(
              icon: Icons.email,
              title: 'Email Support',
              subtitle: 'support@petadoption.com',
              onTap: () => _launchEmail(),
            ),
            _buildContactItem(
              icon: Icons.phone,
              title: 'Phone Support',
              subtitle: '+1 (555) 123-4567',
              onTap: () => _launchPhone(),
            ),
            _buildContactItem(
              icon: Icons.chat,
              title: 'Live Chat',
              subtitle: 'Available 9 AM - 6 PM EST',
              onTap: () => _showChatDialog(context),
            ),

            const SizedBox(height: 32),

            // Tutorials Section
            _buildSectionHeader('Quick Tutorials'),
            _buildTutorialItem(
              icon: Icons.play_circle_outline,
              title: 'Getting Started Guide',
              duration: '2 min',
              onTap: () => _showTutorialDialog(context, 'Getting Started'),
            ),
            _buildTutorialItem(
              icon: Icons.play_circle_outline,
              title: 'Adoption Process',
              duration: '3 min',
              onTap: () => _showTutorialDialog(context, 'Adoption Process'),
            ),
            _buildTutorialItem(
              icon: Icons.play_circle_outline,
              title: 'Pet Care Tips',
              duration: '5 min',
              onTap: () => _showTutorialDialog(context, 'Pet Care Tips'),
            ),

            const SizedBox(height: 32),

            // App Info
            Container(
              padding: const EdgeInsets.all(20),
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
              child: const Column(
                children: [
                  Text(
                    'Pet Adoption App',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '© 2024 Pet Adoption Team',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryGreen),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
            child: Text(
              content,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.secondaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.secondaryBlue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildTutorialItem({
    required IconData icon,
    required String title,
    required String duration,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accentAmber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.accentAmber),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Duration: $duration'),
        trailing: const Icon(Icons.play_arrow, color: AppColors.accentAmber),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@petadoption.com',
      queryParameters: {
        'subject': 'Pet Adoption App Support',
      },
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+15551234567');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text(
          'Our live chat support is currently unavailable. Please try email or phone support instead.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTutorialDialog(BuildContext context, String tutorial) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$tutorial Tutorial'),
        content: Text(
          'Tutorial for $tutorial is coming soon! In the meantime, please check our FAQ section or contact support.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
