import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/customer_service.dart';

class CustomerProvider with ChangeNotifier {
  final CustomerService _customerService = CustomerService();

  List<UserModel> _customers = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCustomers() async {
    _setLoading(true);
    _error = null;
    try {
      _customers = await _customerService.getAllCustomers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleStatus(String uid, bool currentStatus) async {
    _setLoading(true);
    _error = null;
    try {
      bool newStatus = !currentStatus;
      await _customerService.toggleCustomerStatus(uid, newStatus);
      
      final index = _customers.indexWhere((c) => c.uid == uid);
      if (index != -1) {
        _customers[index] = _customers[index].copyWith(isActive: newStatus);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile(UserModel user) async {
    _setLoading(true);
    _error = null;
    try {
      await _customerService.updateProfile(user);
      final index = _customers.indexWhere((c) => c.uid == user.uid);
      if (index != -1) {
        _customers[index] = user;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
