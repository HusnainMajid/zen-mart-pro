import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/vendor_order_service.dart';

class VendorOrderProvider with ChangeNotifier {
  final VendorOrderService _orderService = VendorOrderService();

  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter states
  String _searchQuery = '';
  String? _selectedStatus;
  DateTimeRange? _dateRange;

  List<OrderModel> get orders => _filteredOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters for filters
  String get searchQuery => _searchQuery;
  String? get selectedStatus => _selectedStatus;
  DateTimeRange? get dateRange => _dateRange;

  /// Fetches all orders for a specific shop.
  Future<void> fetchOrders(String shopId) async {
    _setLoading(true);
    try {
      _allOrders = await _orderService.getShopOrders(shopId);
      _applyFilters();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _applyFilters() {
    _filteredOrders = _allOrders.where((order) {
      final matchesSearch = order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.customerName.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _selectedStatus == null || 
          order.status.toLowerCase() == _selectedStatus!.toLowerCase();
      
      bool matchesDate = true;
      if (_dateRange != null) {
        matchesDate = order.orderTime.isAfter(_dateRange!.start) && 
            order.orderTime.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();
    notifyListeners();
  }

  /// Sets search query and applies filters.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Sets status filter and applies filters.
  void setStatusFilter(String? status) {
    _selectedStatus = status == 'All' ? null : status;
    _applyFilters();
  }

  /// Sets date range filter and applies filters.
  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    _applyFilters();
  }

  /// Clears all filters.
  void clearFilters() {
    _searchQuery = '';
    _selectedStatus = null;
    _dateRange = null;
    _applyFilters();
  }

  /// Updates order status.
  Future<bool> updateStatus(String orderId, String newStatus, String shopId) async {
    _setLoading(true);
    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      await fetchOrders(shopId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Accepts an order.
  Future<bool> acceptOrder(String orderId, String shopId) async {
    _setLoading(true);
    try {
      await _orderService.acceptOrder(orderId);
      await fetchOrders(shopId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Rejects an order.
  Future<bool> rejectOrder(String orderId, String shopId) async {
    _setLoading(true);
    try {
      await _orderService.rejectOrder(orderId);
      await fetchOrders(shopId);
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
