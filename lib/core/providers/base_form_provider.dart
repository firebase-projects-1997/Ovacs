import 'package:dartz/dartz.dart';
import 'base_provider.dart';
import '../error/failure.dart';

/// Base provider for form operations and single-item management
/// Provides validation, form state management, and consistent operations
abstract class BaseFormProvider<T> extends BaseProvider {
  T? _data;
  final Map<String, String> _fieldErrors = {};
  bool _isFormValid = true;

  /// The current data being managed
  T? get data => _data;

  /// Field-specific errors
  Map<String, String> get fieldErrors => Map.unmodifiable(_fieldErrors);

  /// Whether the form is valid
  bool get isFormValid => _isFormValid;

  /// Whether there are any field errors
  bool get hasFieldErrors => _fieldErrors.isNotEmpty;

  /// Set the data
  void setData(T? data) {
    _data = data;
    notifyListeners();
  }

  /// Clear all data
  void clearData() {
    _data = null;
    clearFieldErrors();
    reset();
  }

  /// Set error for a specific field
  void setFieldError(String field, String error) {
    _fieldErrors[field] = error;
    _updateFormValidity();
    notifyListeners();
  }

  /// Clear error for a specific field
  void clearFieldError(String field) {
    _fieldErrors.remove(field);
    _updateFormValidity();
    notifyListeners();
  }

  /// Clear all field errors
  void clearFieldErrors() {
    _fieldErrors.clear();
    _updateFormValidity();
    notifyListeners();
  }

  /// Get error for a specific field
  String? getFieldError(String field) {
    return _fieldErrors[field];
  }

  /// Check if a specific field has an error
  bool hasFieldError(String field) {
    return _fieldErrors.containsKey(field);
  }

  /// Update form validity based on field errors
  void _updateFormValidity() {
    _isFormValid = _fieldErrors.isEmpty;
  }

  /// Validate all fields (to be implemented by subclasses)
  bool validateForm() {
    clearFieldErrors();
    performValidation();
    return _isFormValid;
  }

  /// Perform field validation (to be implemented by subclasses)
  void performValidation() {
    // Override in subclasses to implement specific validation logic
  }

  /// Submit form data
  Future<bool> submitForm({
    required Future<Either<Failure, T>> Function() operation,
    String? successMessage,
    bool validateBeforeSubmit = true,
  }) async {
    if (validateBeforeSubmit && !validateForm()) {
      setError('Please fix the form errors before submitting');
      return false;
    }

    return await executeOperationWithData<T>(
      operation: operation,
      successMessage: successMessage,
      onSuccess: (data) {
        _data = data;
      },
    ) != null;
  }

  /// Load data by ID
  Future<bool> loadData({
    required Future<Either<Failure, T>> Function() operation,
    String? successMessage,
  }) async {
    return await executeOperationWithData<T>(
      operation: operation,
      successMessage: successMessage,
      onSuccess: (data) {
        _data = data;
      },
    ) != null;
  }

  /// Update existing data
  Future<bool> updateData({
    required Future<Either<Failure, T>> Function() operation,
    String? successMessage,
    bool validateBeforeUpdate = true,
  }) async {
    if (validateBeforeUpdate && !validateForm()) {
      setError('Please fix the form errors before updating');
      return false;
    }

    return await executeOperationWithData<T>(
      operation: operation,
      successMessage: successMessage,
      onSuccess: (data) {
        _data = data;
      },
    ) != null;
  }

  /// Delete data
  Future<bool> deleteData({
    required Future<Either<Failure, dynamic>> Function() operation,
    String? successMessage,
  }) async {
    return await executeOperation(
      operation: operation,
      successMessage: successMessage,
      onSuccess: () {
        _data = null;
      },
    );
  }

  /// Handle validation errors from API response
  void handleValidationErrors(Map<String, dynamic> errors) {
    clearFieldErrors();
    
    errors.forEach((field, error) {
      if (error is List && error.isNotEmpty) {
        setFieldError(field, error.first.toString());
      } else if (error is String) {
        setFieldError(field, error);
      }
    });
    
    if (hasFieldErrors) {
      setError('Please fix the form errors');
    }
  }

  /// Common validation helpers
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }
}
