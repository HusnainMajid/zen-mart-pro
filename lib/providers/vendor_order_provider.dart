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

  /// Starts listening to shop orders.
  void listenToOrders(String shopId) {
    _setLoading(true);
    _orderService.getShopOrdersStream(shopId).listen((orders) {
      _allOrders = orders;
      _applyFilters();
      _errorMessage = null;
      _setLoading(false);
    }, onError: (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    });
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
    _isLoading = true;
    notifyListeners();
    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Accepts an order.
  Future<bool> acceptOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderService.acceptOrder(orderId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rejects an order.
  Future<bool> rejectOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderService.rejectOrder(orderId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
