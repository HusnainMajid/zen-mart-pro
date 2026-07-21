import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';

class ComplaintProvider with ChangeNotifier {
  final ComplaintService _complaintService = ComplaintService();

  List<ComplaintModel> _complaints = [];
  List<ComplaintModel> _filteredComplaints = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ComplaintModel> get complaints => _filteredComplaints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches all complaints.
  Future<void> fetchComplaints() async {
    _setLoading(true);
    try {
      _complaints = await _complaintService.getAllComplaints();
      _filteredComplaints = List.from(_complaints);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Searches complaints by customer name or subject.
  void searchComplaints(String query) {
    if (query.isEmpty) {
      _filteredComplaints = List.from(_complaints);
    } else {
      _filteredComplaints = _complaints.where((complaint) {
        return complaint.customerName.toLowerCase().contains(query.toLowerCase()) ||
               complaint.subject.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  /// Updates complaint status.
  Future<bool> updateStatus(String id, String status) async {
    _setLoading(true);
    try {
      await _complaintService.updateComplaintStatus(id, status);
      await fetchComplaints();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Replies to a complaint.
  Future<bool> replyToComplaint(String id, String reply) async {
    _setLoading(true);
    try {
      await _complaintService.replyToComplaint(id, reply);
      await fetchComplaints();
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
