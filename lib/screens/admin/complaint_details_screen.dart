import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/complaint_provider.dart';
import '../../models/complaint_model.dart';
import '../../utils/snackbar_helper.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final ComplaintModel complaint;

  const ComplaintDetailsScreen({super.key, required this.complaint});

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  final TextEditingController _replyController = TextEditingController();
  late String _selectedStatus;
  final List<String> _statusOptions = ['pending', 'in_progress', 'resolved', 'closed'];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.complaint.status;
    if (widget.complaint.reply != null) {
      _replyController.text = widget.complaint.reply!;
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String status) async {
    final success = await context.read<ComplaintProvider>().updateStatus(widget.complaint.id, status);
    if (!mounted) return;
    if (success) {
      SnackBarHelper.showSuccess(context, 'Status updated to ${status.replaceAll('_', ' ')}');
      setState(() {
        _selectedStatus = status;
      });
    } else {
      SnackBarHelper.showError(context, 'Failed to update status');
    }
  }

  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) {
      SnackBarHelper.showError(context, 'Please enter a reply');
      return;
    }

    final success = await context.read<ComplaintProvider>().replyToComplaint(
          widget.complaint.id,
          _replyController.text.trim(),
        );

    if (!mounted) return;
    if (success) {
      SnackBarHelper.showSuccess(context, 'Reply sent successfully');
      // If it was pending, maybe move to in_progress or resolved? 
      // For now, just update the status to in_progress if it was pending
      if (_selectedStatus == 'pending') {
        _updateStatus('in_progress');
      }
    } else {
      SnackBarHelper.showError(context, 'Failed to send reply');
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').split(' ').map((str) {
      if (str.isEmpty) return str;
      return str[0].toUpperCase() + str.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(),
                const Divider(height: 32),
                _buildMessageHistory(),
                const Divider(height: 32),
                _buildStatusSection(),
                const SizedBox(height: 24),
                _buildReplySection(provider.isLoading),
                const SizedBox(height: 32),
                if (_selectedStatus != 'closed')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: provider.isLoading ? null : () => _updateStatus('closed'),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Close Complaint', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(76),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.complaint.subject,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16),
                const SizedBox(width: 4),
                Text('Customer: ${widget.complaint.customerName}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Date: ${DateFormat('MMM dd, yyyy HH:mm').format(widget.complaint.createdAt)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conversation History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildChatBubble(
          sender: widget.complaint.customerName,
          message: widget.complaint.message,
          isCustomer: true,
          date: widget.complaint.createdAt,
        ),
        if (widget.complaint.reply != null && widget.complaint.reply!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildChatBubble(
            sender: 'Admin Support',
            message: widget.complaint.reply!,
            isCustomer: false,
            date: widget.complaint.updatedAt,
          ),
        ],
      ],
    );
  }

  Widget _buildChatBubble({
    required String sender,
    required String message,
    required bool isCustomer,
    required DateTime date,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCustomer
            ? Colors.grey.shade100
            : Theme.of(context).colorScheme.primaryContainer.withAlpha(102),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCustomer ? Colors.grey.shade300 : Theme.of(context).colorScheme.primaryContainer,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sender,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                DateFormat('MMM dd, HH:mm').format(date),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Row(
      children: [
        const Text(
          'Status:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: _statusOptions.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(_formatStatus(status)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null && value != _selectedStatus) {
                _updateStatus(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReplySection(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Send a Reply',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _replyController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Type your reply here...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitReply,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Submit Reply'),
          ),
        ),
      ],
    );
  }
}
