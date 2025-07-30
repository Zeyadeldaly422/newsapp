import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/cubits/auth_cubit.dart';
import 'package:news_app/cubits/auth_state.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/utils/validation_utils.dart';
import 'package:news_app/widgets/custom_text_form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  void _submitRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      final userData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'dateOfBirth': _dateOfBirthController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
      };
      context.read<AuthCubit>().register(userData);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 128, 1, 255),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistered) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful! Please login.'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Join Us!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create your account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 19,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomTextFormField(
                          controller: _firstNameController,
                          labelText: 'First Name',
                          hintText: 'Enter your first name',
                          prefixIcon: Icons.person_outline,
                          validator: ValidationUtils.validateName,
                        ),
                        const SizedBox(height: 18),
                        CustomTextFormField(
                          controller: _lastNameController,
                          labelText: 'Last Name',
                          hintText: 'Enter your last name',
                          prefixIcon: Icons.person_outline,
                          validator: ValidationUtils.validateName,
                        ),
                        const SizedBox(height: 18),
                        CustomTextFormField(
                          controller: _dateOfBirthController,
                          labelText: 'Date of Birth',
                          hintText: 'YYYY-MM-DD',
                          keyboardType: TextInputType.datetime,
                          prefixIcon: Icons.calendar_today,
                          validator: ValidationUtils.validateDateOfBirth,
                        ),
                        const SizedBox(height: 18),
                        CustomTextFormField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: ValidationUtils.validateEmail,
                        ),
                        const SizedBox(height: 18),
                        CustomTextFormField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'Enter a strong password',
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          validator: ValidationUtils.validatePassword,
                        ),
                        const SizedBox(height: 18),
                        CustomTextFormField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          hintText: 'Re-enter your password',
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state is AuthLoading ? null : _submitRegister,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: const Color.fromARGB(255, 72, 56, 119),
                                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                              ),
                              child: state is AuthLoading
                                  ? const CircularProgressIndicator(color: Color.fromARGB(255, 255, 255, 255))
                                  : const Text(
                                      'Register',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}