/// Profile Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  
  String? _livingSpace;
  bool _hasYard = false;
  bool _hasChildren = false;
  bool _hasOtherPets = false;
  String? _activityLevel;
  String? _experienceWithPets;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    _firstNameController = TextEditingController(text: user?.firstName);
    _lastNameController = TextEditingController(text: user?.lastName);
    _phoneController = TextEditingController(text: user?.phone);
    _addressController = TextEditingController(text: user?.address);
    
    _livingSpace = user?.livingSpace;
    _hasYard = user?.hasYard ?? false;
    _hasChildren = user?.hasChildren ?? false;
    _hasOtherPets = user?.hasOtherPets ?? false;
    _activityLevel = user?.activityLevel;
    _experienceWithPets = user?.experienceWithPets;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.updateProfile({
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'living_space': _livingSpace,
      'has_yard': _hasYard,
      'has_children': _hasChildren,
      'has_other_pets': _hasOtherPets,
      'activity_level': _activityLevel,
      'experience_with_pets': _experienceWithPets,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Profile updated!' : 'Update failed'),
          backgroundColor: success ? AppColors.primaryGreen : AppColors.criticalRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Basic Info Section
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Lifestyle Section (for AI matching)
                Text(
                  'Lifestyle (for AI Matching)',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'This helps us recommend the best pets for you',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                
                // Living Space
                DropdownButtonFormField<String>(
                  value: _livingSpace,
                  decoration: const InputDecoration(
                    labelText: 'Living Space',
                    prefixIcon: Icon(Icons.home),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
                    DropdownMenuItem(value: 'house', child: Text('House')),
                    DropdownMenuItem(value: 'farm', child: Text('Farm/Large Property')),
                  ],
                  onChanged: (value) {
                    setState(() => _livingSpace = value);
                  },
                ),
                const SizedBox(height: 16),
                
                SwitchListTile(
                  title: const Text('I have a yard'),
                  subtitle: const Text('Outdoor space for pets'),
                  value: _hasYard,
                  onChanged: (value) {
                    setState(() => _hasYard = value);
                  },
                ),
                
                SwitchListTile(
                  title: const Text('I have children'),
                  subtitle: const Text('Kids in the household'),
                  value: _hasChildren,
                  onChanged: (value) {
                    setState(() => _hasChildren = value);
                  },
                ),
                
                SwitchListTile(
                  title: const Text('I have other pets'),
                  subtitle: const Text('Existing pets at home'),
                  value: _hasOtherPets,
                  onChanged: (value) {
                    setState(() => _hasOtherPets = value);
                  },
                ),
                const SizedBox(height: 16),
                
                // Activity Level
                DropdownButtonFormField<String>(
                  value: _activityLevel,
                  decoration: const InputDecoration(
                    labelText: 'Your Activity Level',
                    prefixIcon: Icon(Icons.directions_run),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low - Prefer relaxing')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium - Moderate activity')),
                    DropdownMenuItem(value: 'high', child: Text('High - Very active')),
                  ],
                  onChanged: (value) {
                    setState(() => _activityLevel = value);
                  },
                ),
                const SizedBox(height: 16),
                
                // Experience
                DropdownButtonFormField<String>(
                  value: _experienceWithPets,
                  decoration: const InputDecoration(
                    labelText: 'Pet Experience',
                    prefixIcon: Icon(Icons.pets),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('None - First time pet owner')),
                    DropdownMenuItem(value: 'some', child: Text('Some - Had pets before')),
                    DropdownMenuItem(value: 'experienced', child: Text('Experienced - Lifelong pet owner')),
                  ],
                  onChanged: (value) {
                    setState(() => _experienceWithPets = value);
                  },
                ),
                const SizedBox(height: 32),
                
                // Save Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _saveProfile,
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Profile'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
