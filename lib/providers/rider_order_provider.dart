import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/rider_order_service.dart';

class RiderOrderProvider with ChangeNotifier {
  final RiderOrderService _orderService = RiderOrderService();

  List<OrderModel> _availableOrders = [];
  List<OrderModel> _myDeliveries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get availableOrders => _availableOrders;
  List<OrderModel> get myDeliveries => _myDeliveries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get activeDeliveriesCount => _myDeliveries.where((o) => o.status != 'delivered' && o.status != 'cancelled').length;
  int get completedDeliveriesCount => _myDeliveries.where((o) => o.status == 'delivered').length;
  double get totalEarnings => _myDeliveries.where((o) => o.status == 'delivered').fold(0.0, (sum, o) => sum + 10.0); // Assume $10 per delivery

  /// Starts listening to available orders for pickup
  void listenToAvailableOrders() {
    _orderService.getAvailableOrders().listen((orders) {
      _availableOrders = orders;
      notifyListeners();
    });
  }

  /// Starts listening to active deliveries for a specific rider
  void listenToMyDeliveries(String riderId) {
    _orderService.getRiderDeliveries(riderId).listen((orders) {
      _myDeliveries = orders;
      notifyListeners();
    });
  }

  /// Accept a delivery
  Future<bool> acceptDelivery(String orderId, String riderId, String riderName) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderService.acceptDelivery(orderId, riderId, riderName);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update delivery status
  Future<bool> updateStatus(String orderId, String status) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderService.updateDeliveryStatus(orderId, status);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
