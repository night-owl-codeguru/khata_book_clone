import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class ExportService {
  static const String _appName = 'KhataBook';

  // Export data to CSV format
  static Future<String> exportToCSV({
    required Map<String, dynamic> reportData,
    String? fileName,
  }) async {
    try {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final defaultFileName = fileName ?? 'report_$timestamp.csv';

      // Prepare CSV data
      final csvData = _prepareCSVData(reportData);

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(csvData);

      // Get directory for saving file
      final directory = await _getExportDirectory();
      final filePath = '${directory.path}/$defaultFileName';

      // Write file
      final file = File(filePath);
      await file.writeAsString(csvString);

      return filePath;
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  // Export data to PDF format
  static Future<String> exportToPDF({
    required Map<String, dynamic> reportData,
    String? fileName,
  }) async {
    try {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final defaultFileName = fileName ?? 'report_$timestamp.pdf';

      // Create PDF document
      final pdf = pw.Document();

      // Add content to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => _buildPDFContent(reportData),
        ),
      );

      // Get directory for saving file
      final directory = await _getExportDirectory();
      final filePath = '${directory.path}/$defaultFileName';

      // Save PDF
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }

  // Share file using system share dialog
  static Future<void> shareFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      await Share.shareXFiles([
        XFile(filePath),
      ], text: '$_appName Report Export');
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }

  // Get appropriate directory for exports
  static Future<Directory> _getExportDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final exportDir = Directory('${directory.path}/$_appName/Exports');
        if (!await exportDir.exists()) {
          await exportDir.create(recursive: true);
        }
        return exportDir;
      }
    }

    // For iOS and other platforms, use documents directory
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/Exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  // Prepare CSV data from report data
  static List<List<dynamic>> _prepareCSVData(Map<String, dynamic> reportData) {
    final csvData = <List<dynamic>>[];

    // Add header
    csvData.add(['KhataBook Report Export']);
    csvData.add([
      'Generated on',
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    ]);
    csvData.add([]); // Empty row

    // Summary section
    csvData.add(['SUMMARY']);
    csvData.add(['Metric', 'Value']);
    csvData.add([
      'Total Credit',
      '₹${reportData['totalCredit']?.toStringAsFixed(2) ?? '0.00'}',
    ]);
    csvData.add([
      'Total Debit',
      '₹${reportData['totalDebit']?.toStringAsFixed(2) ?? '0.00'}',
    ]);
    csvData.add([
      'Net Balance',
      '₹${reportData['balance']?.toStringAsFixed(2) ?? '0.00'}',
    ]);
    csvData.add([
      'Total Transactions',
      reportData['transactionCount']?.toString() ?? '0',
    ]);
    csvData.add([]); // Empty row

    // Top customers section
    if (reportData['topCustomers'] != null) {
      csvData.add(['TOP CUSTOMERS']);
      csvData.add(['Customer Name', 'Amount (₹)']);
      final customers = reportData['topCustomers'] as List;
      for (final customer in customers) {
        csvData.add([
          customer['name'] ?? '',
          customer['amount']?.toStringAsFixed(2) ?? '0.00',
        ]);
      }
      csvData.add([]); // Empty row
    }

    // Payment methods section
    if (reportData['paymentMethods'] != null) {
      csvData.add(['PAYMENT METHODS']);
      csvData.add(['Method', 'Percentage (%)']);
      final methods = reportData['paymentMethods'] as Map;
      methods.forEach((method, percentage) {
        csvData.add([method.toUpperCase(), '$percentage%']);
      });
    }

    return csvData;
  }

  // Build PDF content
  static List<pw.Widget> _buildPDFContent(Map<String, dynamic> reportData) {
    final widgets = <pw.Widget>[];

    // Header
    widgets.add(
      pw.Header(
        level: 0,
        child: pw.Text(
          '$_appName Report',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
      ),
    );

    widgets.add(pw.SizedBox(height: 10));

    // Generation timestamp
    widgets.add(
      pw.Text(
        'Generated on: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
      ),
    );

    widgets.add(pw.SizedBox(height: 20));

    // Summary section
    widgets.add(
      pw.Header(
        level: 1,
        child: pw.Text(
          'Summary',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
      ),
    );

    widgets.add(pw.SizedBox(height: 10));

    final summaryData = [
      [
        'Total Credit',
        '₹${reportData['totalCredit']?.toStringAsFixed(2) ?? '0.00'}',
      ],
      [
        'Total Debit',
        '₹${reportData['totalDebit']?.toStringAsFixed(2) ?? '0.00'}',
      ],
      [
        'Net Balance',
        '₹${reportData['balance']?.toStringAsFixed(2) ?? '0.00'}',
      ],
      ['Total Transactions', reportData['transactionCount']?.toString() ?? '0'],
    ];

    widgets.add(
      pw.TableHelper.fromTextArray(
        headers: ['Metric', 'Value'],
        data: summaryData,
        border: pw.TableBorder.all(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        cellAlignment: pw.Alignment.centerLeft,
        cellPadding: const pw.EdgeInsets.all(8),
      ),
    );

    widgets.add(pw.SizedBox(height: 20));

    // Top customers section
    if (reportData['topCustomers'] != null) {
      widgets.add(
        pw.Header(
          level: 1,
          child: pw.Text(
            'Top Customers',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ),
      );

      widgets.add(pw.SizedBox(height: 10));

      final customers = reportData['topCustomers'] as List;
      final customerData = customers
          .map(
            (customer) => [
              customer['name'] ?? '',
              '₹${customer['amount']?.toStringAsFixed(2) ?? '0.00'}',
            ],
          )
          .toList();

      widgets.add(
        pw.TableHelper.fromTextArray(
          headers: ['Customer Name', 'Amount'],
          data: customerData,
          border: pw.TableBorder.all(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(8),
        ),
      );

      widgets.add(pw.SizedBox(height: 20));
    }

    // Payment methods section
    if (reportData['paymentMethods'] != null) {
      widgets.add(
        pw.Header(
          level: 1,
          child: pw.Text(
            'Payment Methods',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ),
      );

      widgets.add(pw.SizedBox(height: 10));

      final methods = reportData['paymentMethods'] as Map;
      final methodData = methods.entries
          .map((entry) => [entry.key.toUpperCase(), '${entry.value}%'])
          .toList();

      widgets.add(
        pw.TableHelper.fromTextArray(
          headers: ['Method', 'Percentage'],
          data: methodData,
          border: pw.TableBorder.all(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(8),
        ),
      );
    }

    return widgets;
  }

  // Export with custom data (for future use with real API data)
  static Future<String> exportReport({
    required String format,
    required Map<String, dynamic> data,
    String? customFileName,
  }) async {
    switch (format.toLowerCase()) {
      case 'csv':
        return exportToCSV(reportData: data, fileName: customFileName);
      case 'pdf':
        return exportToPDF(reportData: data, fileName: customFileName);
      default:
        throw Exception('Unsupported export format: $format');
    }
  }
}
