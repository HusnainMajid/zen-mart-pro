import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/customer_order_service.dart';

class CustomerOrderProvider with ChangeNotifier {
  final CustomerOrderService _orderService = CustomerOrderService();
  List<OrderModel> _orders = [];
  OrderModel? _currentTrackingOrder;
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  OrderModel? get currentTrackingOrder => _currentTrackingOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CustomerOrderProvider() {
    _fetchOrders();
  }

  void _fetchOrders() {
    _isLoading = true;
    _orderService.getCustomerOrders().listen((orders) {
      _orders = orders;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> placeOrder(OrderModel order) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _orderService.placeOrder(order);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      _error = null;
      await _orderService.cancelOrder(orderId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void startTracking(String orderId) {
    _orderService.getOrderTracking(orderId).listen((order) {
      _currentTrackingOrder = order;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      notifyListeners();
    });
  }

  void stopTracking() {
    _currentTrackingOrder = null;
    notifyListeners();
  }
}
