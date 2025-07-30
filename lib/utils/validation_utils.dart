import 'package:email_validator/email_validator.dart';

class ValidationUtils {
  static var validateDateOfBirth;

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty.';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long.';
    }
    if (RegExp(r'[^a-zA-Z\s]').hasMatch(value)) {
      return 'Name can only contain letters and spaces.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty.';
    }
    if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Password must contain an uppercase letter.';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'Password must contain a lowercase letter.';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Password must contain a number.';
    }
    if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(value)) {
      return 'Password must contain a special character.';
    }
    return null;
  }
}