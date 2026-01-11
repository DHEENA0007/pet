/// Add Pet Screen

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/pet_provider.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageYearsController = TextEditingController();
  final _ageMonthsController = TextEditingController();
  final _colorController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _personalityController = TextEditingController();
  
  int? _selectedCategory;
  String _gender = 'male';
  String _size = 'medium';
  String _activityLevel = 'medium';
  bool _isVaccinated = false;
  bool _isNeutered = false;
  bool _goodWithChildren = true;
  bool _goodWithPets = true;

  @override
  void initState() {
    super.initState();
    Provider.of<PetProvider>(context, listen: false).fetchCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageYearsController.dispose();
    _ageMonthsController.dispose();
    _colorController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    _personalityController.dispose();
    super.dispose();
  }

  Future<void> _submitPet() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.criticalRed,
        ),
      );
      return;
    }

    final provider = Provider.of<PetProvider>(context, listen: false);
    
    final petData = {
      'name': _nameController.text.trim(),
      'category': _selectedCategory,
      'breed': _breedController.text.trim(),
      'age_years': int.tryParse(_ageYearsController.text) ?? 0,
      'age_months': int.tryParse(_ageMonthsController.text) ?? 0,
      'gender': _gender,
      'size': _size,
      'color': _colorController.text.trim(),
      'weight': double.tryParse(_weightController.text),
      'description': _descriptionController.text.trim(),
      'personality': _personalityController.text.trim(),
      'is_vaccinated': _isVaccinated,
      'is_neutered': _isNeutered,
      'good_with_children': _goodWithChildren,
      'good_with_other_pets': _goodWithPets,
      'activity_level': _activityLevel,
    };

    final success = await provider.createPet(petData);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet posted successfully! Waiting for approval.'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to post pet'),
            backgroundColor: AppColors.criticalRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Pet'),
      ),
      body: Consumer<PetProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info Card
                Card(
                  color: AppColors.accentAmber.withOpacity(0.1),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: AppColors.accentAmber),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your pet will be reviewed by admin before being visible to adopters.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Basic Information Section
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                // Category Dropdown
                DropdownButtonFormField<int>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: provider.categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                  },
                ),
                const SizedBox(height: 16),
                
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Pet Name *',
                    prefixIcon: Icon(Icons.pets),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pet name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Breed
                TextFormField(
                  controller: _breedController,
                  decoration: const InputDecoration(
                    labelText: 'Breed',
                    prefixIcon: Icon(Icons.pets),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Age
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ageYearsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age (Years)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _ageMonthsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Months',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Gender
                Text('Gender', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Male'),
                        value: 'male',
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() => _gender = value!);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Female'),
                        value: 'female',
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() => _gender = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Size
                Text('Size', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'small', label: Text('Small')),
                    ButtonSegment(value: 'medium', label: Text('Medium')),
                    ButtonSegment(value: 'large', label: Text('Large')),
                  ],
                  selected: {_size},
                  onSelectionChanged: (value) {
                    setState(() => _size = value.first);
                  },
                ),
                const SizedBox(height: 16),
                
                // Color and Weight
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _colorController,
                        decoration: const InputDecoration(
                          labelText: 'Color',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Description Section
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'About this pet',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _personalityController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Personality traits',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Health Section
                Text(
                  'Health Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                SwitchListTile(
                  title: const Text('Vaccinated'),
                  value: _isVaccinated,
                  onChanged: (value) {
                    setState(() => _isVaccinated = value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Neutered/Spayed'),
                  value: _isNeutered,
                  onChanged: (value) {
                    setState(() => _isNeutered = value);
                  },
                ),
                const SizedBox(height: 24),
                
                // Compatibility Section
                Text(
                  'Compatibility',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                SwitchListTile(
                  title: const Text('Good with children'),
                  value: _goodWithChildren,
                  onChanged: (value) {
                    setState(() => _goodWithChildren = value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Good with other pets'),
                  value: _goodWithPets,
                  onChanged: (value) {
                    setState(() => _goodWithPets = value);
                  },
                ),
                const SizedBox(height: 16),
                
                // Activity Level
                Text('Activity Level', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'low', label: Text('Low')),
                    ButtonSegment(value: 'medium', label: Text('Medium')),
                    ButtonSegment(value: 'high', label: Text('High')),
                  ],
                  selected: {_activityLevel},
                  onSelectionChanged: (value) {
                    setState(() => _activityLevel = value.first);
                  },
                ),
                const SizedBox(height: 32),
                
                // Submit Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _submitPet,
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Post Pet for Adoption'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
