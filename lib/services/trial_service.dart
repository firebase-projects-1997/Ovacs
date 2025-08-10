import 'package:flutter/material.dart';
import '../core/constants/storage_keys.dart';
import 'storage_service.dart';

class TrialService extends ChangeNotifier {
  final StorageService _storageService;
  
  // Trial expires on August 14, 2025
  static final DateTime _trialExpiryDate = DateTime(2025, 8, 14, 23, 59, 59);
  
  bool _isTrialExpired = false;
  bool _isTrialActivated = false;
  DateTime? _trialExpiryDateTime;
  
  TrialService(this._storageService);
  
  bool get isTrialExpired => _isTrialExpired;
  bool get isTrialActivated => _isTrialActivated;
  DateTime? get trialExpiryDateTime => _trialExpiryDateTime;
  
  /// Get remaining days in trial
  int get remainingDays {
    if (_isTrialExpired) return 0;
    final now = DateTime.now();
    final difference = _trialExpiryDate.difference(now);
    return difference.inDays.clamp(0, double.infinity).toInt();
  }
  
  /// Get remaining hours in trial
  int get remainingHours {
    if (_isTrialExpired) return 0;
    final now = DateTime.now();
    final difference = _trialExpiryDate.difference(now);
    return difference.inHours.clamp(0, double.infinity).toInt();
  }
  
  /// Initialize trial service and check trial status
  Future<void> init() async {
    // Check if trial was previously activated
    _isTrialActivated = _storageService.getBool(StorageKeys.trialActivated) ?? false;
    
    // Get stored expiry date or use default
    final storedExpiry = _storageService.getString(StorageKeys.trialExpiry);
    if (storedExpiry != null) {
      try {
        _trialExpiryDateTime = DateTime.parse(storedExpiry);
      } catch (e) {
        _trialExpiryDateTime = _trialExpiryDate;
      }
    } else {
      _trialExpiryDateTime = _trialExpiryDate;
    }
    
    // Activate trial if not already activated
    if (!_isTrialActivated) {
      await _activateTrial();
    }
    
    // Check if trial has expired
    _checkTrialStatus();
    
    notifyListeners();
  }
  
  /// Activate the trial period
  Future<void> _activateTrial() async {
    _isTrialActivated = true;
    _trialExpiryDateTime = _trialExpiryDate;
    
    await _storageService.setBool(StorageKeys.trialActivated, true);
    await _storageService.setString(
      StorageKeys.trialExpiry, 
      _trialExpiryDate.toIso8601String(),
    );
    
    notifyListeners();
  }
  
  /// Check if trial has expired
  void _checkTrialStatus() {
    final now = DateTime.now();
    _isTrialExpired = now.isAfter(_trialExpiryDate);
  }
  
  /// Force check trial status (can be called periodically)
  void checkTrialStatus() {
    _checkTrialStatus();
    notifyListeners();
  }
  
  /// Get formatted expiry date string
  String getFormattedExpiryDate() {
    if (_trialExpiryDateTime == null) return 'Unknown';
    
    final date = _trialExpiryDateTime!;
    return '${date.day.toString().padLeft(2, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.year}';
  }
  
  /// Get trial status message
  String getTrialStatusMessage() {
    if (_isTrialExpired) {
      return 'Your trial has expired on ${getFormattedExpiryDate()}';
    }
    
    final days = remainingDays;
    if (days > 1) {
      return 'Trial expires in $days days (${getFormattedExpiryDate()})';
    } else if (days == 1) {
      return 'Trial expires tomorrow (${getFormattedExpiryDate()})';
    } else {
      final hours = remainingHours;
      if (hours > 1) {
        return 'Trial expires in $hours hours';
      } else {
        return 'Trial expires soon';
      }
    }
  }
  
  /// Reset trial (for testing purposes - should be removed in production)
  Future<void> resetTrial() async {
    await _storageService.remove(StorageKeys.trialActivated);
    await _storageService.remove(StorageKeys.trialExpiry);
    _isTrialActivated = false;
    _isTrialExpired = false;
    _trialExpiryDateTime = null;
    await init();
  }
}
