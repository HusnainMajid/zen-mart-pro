import 'package:flutter/material.dart';
import '../models/sales_report_model.dart';
import '../services/vendor_report_service.dart';

class VendorReportProvider with ChangeNotifier {
  final VendorReportService _reportService = VendorReportService();

  SalesReportModel? _currentReport;
  bool _isLoading = false;
  bool _isExporting = false;
  String? _errorMessage;

  SalesReportModel? get currentReport => _currentReport;
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;
  String? get errorMessage => _errorMessage;

  /// Generates a report for today.
  Future<void> generateDailyReport(String shopId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    await _generateReport(shopId, start, end);
  }

  /// Generates a report for the last 7 days.
  Future<void> generateWeeklyReport(String shopId) async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    await _generateReport(shopId, start, now);
  }

  /// Generates a report for the current month.
  Future<void> generateMonthlyReport(String shopId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    await _generateReport(shopId, start, now);
  }

  /// Internal method to fetch report from service.
  Future<void> _generateReport(String shopId, DateTime start, DateTime end) async {
    _setLoading(true);
    try {
      _currentReport = await _reportService.generateSalesReport(shopId, start, end);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Exports the current report to PDF.
  Future<bool> exportToPdf() async {
    if (_currentReport == null) {
      _errorMessage = 'No report available to export';
      notifyListeners();
      return false;
    }

    _setExporting(true);
    try {
      await _reportService.exportReportToPdf(_currentReport!);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setExporting(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setExporting(bool value) {
    _isExporting = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
