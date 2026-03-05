/// Register Screen

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      context.go('/login');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Registration failed'),
          backgroundColor: AppColors.criticalRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.milkyCream,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Background Accents
              Positioned(
                top: -80,
                left: -80,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.softSage.withOpacity(0.2),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                right: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondarySoftOrange.withOpacity(0.15),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      // Back Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.accentDarkBrown),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.accentDarkBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start your journey with us',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Form
                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: _buildTextField(_firstNameController, 'First Name')),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildTextField(_lastNameController, 'Last Name')),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(_usernameController, 'Username', icon: Icons.person_outline),
                                const SizedBox(height: 16),
                                _buildTextField(_emailController, 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                                const SizedBox(height: 16),
                                _buildTextField(_phoneController, 'Phone (Optional)', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  _passwordController, 
                                  'Password', 
                                  icon: Icons.lock_outline, 
                                  isPassword: true,
                                  isObscure: _obscurePassword,
                                  onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  _confirmPasswordController, 
                                  'Confirm Password', 
                                  icon: Icons.lock_outline, 
                                  isPassword: true,
                                  isObscure: _obscureConfirmPassword,
                                  onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                ),
                                const SizedBox(height: 40),
                                
                                // Register Button
                                Consumer<AuthProvider>(
                                  builder: (context, auth, child) {
                                    return Container(
                                      height: 60,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryWarmBrown.withOpacity(0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: auth.isLoading ? null : _register,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: auth.isLoading
                                            ? const CircularProgressIndicator(color: Colors.white)
                                            : const Text(
                                                'Sign Up',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                
                                // Login Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Already have an account? ',
                                      style: TextStyle(color: AppColors.textGrey),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.go('/login'),
                                      child: const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          color: AppColors.primaryWarmBrown,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
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

  Widget _buildTextField(
    TextEditingController controller, 
    String label, {
    IconData? icon,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter your ${label.toLowerCase()}',
          prefixIcon: icon != null ? Icon(icon, color: AppColors.primaryWarmBrown) : null,
          suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textGrey,
                  ),
                  onPressed: onToggleObscure,
                ) 
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            // Simple validation for required fields
             if (!label.contains('Optional')) {
                return '$label is required';
             }
          }
          if (label == 'Email' && value != null && value.isNotEmpty && !value.contains('@')) {
            return 'Invalid email';
          }
          if (label == 'Password' && value != null && value.length < 8) {
            return 'Min 8 characters';
          }
          if (label == 'Confirm Password' && value != _passwordController.text) {
             return 'Passwords mismatch';
          }
          return null;
        },
      ),
    );
  }
}
