import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order_model.dart';
import '../models/sales_report_model.dart';

/// Service to generate and export sales reports for vendors
class VendorReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Aggregate order data for a specific period and return a SalesReportModel
  Future<SalesReportModel> generateSalesReport(String shopId, DateTime start, DateTime end) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('shopId', isEqualTo: shopId)
          .where('orderTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('orderTime', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      final List<OrderModel> orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      double totalRevenue = 0;
      int completedOrders = 0;
      int cancelledOrders = 0;
      Map<String, Map<String, dynamic>> productSales = {};

      for (var order in orders) {
        final String status = order.status.toLowerCase();
        
        // Count revenue and completion only for delivered orders
        if (status == 'delivered') {
          totalRevenue += order.total;
          completedOrders++;
        } else if (status == 'cancelled') {
          cancelledOrders++;
        }

        // Aggregate product sales data from items
        for (var item in order.items) {
          if (productSales.containsKey(item.productId)) {
            productSales[item.productId]!['quantity'] += item.quantity;
            productSales[item.productId]!['total'] += item.total;
          } else {
            productSales[item.productId] = {
              'name': item.name,
              'quantity': item.quantity,
              'total': item.total,
            };
          }
        }
      }

      // Sort and take top 5 best selling products
      final List<Map<String, dynamic>> bestSelling = productSales.values.toList();
      bestSelling.sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));

      return SalesReportModel(
        date: DateTime.now(),
        totalRevenue: totalRevenue,
        totalOrders: orders.length,
        completedOrders: completedOrders,
        cancelledOrders: cancelledOrders,
        bestSellingProducts: bestSelling.take(5).toList(),
      );
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        debugPrint('CRITICAL: Firestore index required. Create it here: ${e.message}');
        throw 'A required Firestore index is missing. Please check the logs or create it using the link: ${e.message}';
      }
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to generate sales report: ${e.toString()}';
    }
  }

  /// Export SalesReportModel to a PDF document and share it
  Future<void> exportReportToPdf(SalesReportModel report) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('Zen Mart Pro - Sales Report', 
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Report Date: ${report.date.toString().split('.')[0]}'),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text('Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Bullet(text: 'Total Orders: ${report.totalOrders}'),
                pw.Bullet(text: 'Total Revenue: \$${report.totalRevenue.toStringAsFixed(2)}'),
                pw.Bullet(text: 'Completed Orders: ${report.completedOrders}'),
                pw.Bullet(text: 'Cancelled Orders: ${report.cancelledOrders}'),
                pw.SizedBox(height: 20),
                pw.Text('Top 5 Best Selling Products', 
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  headers: ['Product Name', 'Quantity', 'Sales Revenue'],
                  data: report.bestSellingProducts.map((p) => [
                    p['name'],
                    p['quantity'].toString(),
                    '\$${p['total'].toStringAsFixed(2)}',
                  ]).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
              ],
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Sales_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to export PDF: ${e.toString()}';
    }
  }
}
