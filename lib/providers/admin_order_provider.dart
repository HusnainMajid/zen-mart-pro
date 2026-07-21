import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/admin_order_service.dart';

class AdminOrderProvider with ChangeNotifier {
  final AdminOrderService _orderService = AdminOrderService();

  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String? _selectedStatus;
  String? _selectedVendor;

  List<OrderModel> get orders => _filteredOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches all orders across all vendors.
  Future<void> fetchAllOrders() async {
    _setLoading(true);
    try {
      _allOrders = await _orderService.getAllOrders();
      _applyFilters();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Sets search query and applies filters.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Sets status filter and applies filters.
  void setStatusFilter(String? status) {
    _selectedStatus = status;
    _applyFilters();
  }

  /// Sets vendor filter and applies filters.
  void setVendorFilter(String? vendorId) {
    _selectedVendor = vendorId;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredOrders = _allOrders.where((order) {
      final matchesSearch = order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           order.customerName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == null || order.status == _selectedStatus;
      final matchesVendor = _selectedVendor == null || order.vendorId == _selectedVendor;
      return matchesSearch && matchesStatus && matchesVendor;
    }).toList();
    notifyListeners();
  }

  /// Updates order status.
  Future<bool> updateStatus(String orderId, String status) async {
    _setLoading(true);
    try {
      await _orderService.updateOrderStatus(orderId, status);
      await fetchAllOrders();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedStatus = null;
    _selectedVendor = null;
    _filteredOrders = List.from(_allOrders);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
