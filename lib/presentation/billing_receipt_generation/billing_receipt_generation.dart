import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import '../../core/user_service.dart';
import './widgets/communication_options_widget.dart';
import './widgets/editable_fields_widget.dart';
import './widgets/receipt_preview_widget.dart';

class BillingReceiptGeneration extends StatefulWidget {
  const BillingReceiptGeneration({super.key});

  @override
  State<BillingReceiptGeneration> createState() =>
      _BillingReceiptGenerationState();
}

class _BillingReceiptGenerationState extends State<BillingReceiptGeneration> {
  bool _isEditing = false;
  bool _isProcessing = false;
  bool _isLoading = true;
  Map<String, String> _validationErrors = {};
  late Map<String, dynamic> _receiptData;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchBillingData();
  }

  Future<void> _fetchBillingData() async {
    try {
      _receiptData = await _userService.fetchBillingData();
      _calculateTotalAmount();
    } catch (e) {
      // On error: do not fall back to hard-coded mock data. Provide
      // an empty state so the UI can show an explicit retry action.
      _receiptData = {};
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load billing data: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppTheme.lightTheme.colorScheme.onPrimary,
              onPressed: () {
                _fetchBillingData();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _calculateTotalAmount() {
    // Be defensive about types coming from the backend.
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final consumption = parseDouble(_receiptData["consumption"]);
    final rate = parseDouble(_receiptData["ratePerCubicMeter"]);
    final basicCharge = parseDouble(_receiptData["basicCharge"]);
    final penalties = parseDouble(_receiptData["penalties"]);

    final consumptionCharge = consumption * rate;
    final total = basicCharge + consumptionCharge + penalties;

    if (mounted) {
      setState(() {
        _receiptData["totalAmount"] = total.toStringAsFixed(2);
      });
    } else {
      _receiptData["totalAmount"] = total.toStringAsFixed(2);
    }
  }

  void _onFieldChanged(String fieldKey, dynamic value) {
    setState(() {
      _receiptData[fieldKey] = value;
      _validationErrors.remove(fieldKey);
    });

    if (fieldKey == 'ratePerCubicMeter' ||
        fieldKey == 'basicCharge' ||
        fieldKey == 'penalties') {
      _calculateTotalAmount();
    }
  }

  bool _validateFields() {
    _validationErrors.clear();

    final rateVal = parseDouble(_receiptData["ratePerCubicMeter"]);
    final basicVal = parseDouble(_receiptData["basicCharge"]);
    final penaltiesVal = parseDouble(_receiptData["penalties"]);

    if (rateVal <= 0) {
      _validationErrors["ratePerCubicMeter"] = "Rate must be greater than 0";
    }

    if (basicVal < 0) {
      _validationErrors["basicCharge"] = "Basic charge cannot be negative";
    }

    if (penaltiesVal < 0) {
      _validationErrors["penalties"] = "Penalties cannot be negative";
    }

    final billingPeriod = _receiptData["billingPeriod"] as String;
    if (billingPeriod.trim().isEmpty) {
      _validationErrors["billingPeriod"] = "Billing period is required";
    }

    final dueDate = _receiptData["dueDate"] as String;
    if (dueDate.trim().isEmpty) {
      _validationErrors["dueDate"] = "Due date is required";
    }

    return _validationErrors.isEmpty;
  }

  Future<void> _generatePDF() async {
    if (!_validateFields()) {
      setState(() {});
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BARANGAY ${(_receiptData["barangayName"] as String).toUpperCase()}',
                          style: pw.TextStyle(
                              fontSize: 20, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('Water Utility Billing Receipt',
                            style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Receipt #: ${_receiptData["receiptNumber"]}'),
                        pw.Text('Date: ${_receiptData["issueDate"]}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Homeowner Details
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('HOMEOWNER DETAILS',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Text('Name: ${_receiptData["homeownerName"]}'),
                      pw.Text('Address: ${_receiptData["address"]}'),
                      pw.Text('Meter No: ${_receiptData["meterNumber"]}'),
                      pw.Text('Purok: ${_receiptData["purok"]}'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 15),

                // Consumption Breakdown
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('CONSUMPTION BREAKDOWN',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Text(
                          'Billing Period: ${_receiptData["billingPeriod"]}'),
                      pw.Text(
                          'Previous Reading: ${_receiptData["previousReading"]} cu.m'),
                      pw.Text(
                          'Current Reading: ${_receiptData["currentReading"]} cu.m'),
                      pw.Text(
                          'Consumption: ${_receiptData["consumption"]} cu.m'),
                      pw.Divider(),
                      pw.Text(
                          'Rate per cu.m: ₱${_receiptData["ratePerCubicMeter"]}'),
                      pw.Text('Basic Charge: ₱${_receiptData["basicCharge"]}'),
                      if (parseDouble(_receiptData["penalties"]) > 0)
                        pw.Text('Penalties: ₱${_receiptData["penalties"]}'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 15),

                // Payment Summary
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 2),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('TOTAL AMOUNT DUE:',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 16)),
                          pw.Text('₱${_receiptData["totalAmount"]}',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 18)),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Due Date:'),
                          pw.Text('${_receiptData["dueDate"]}',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Footer
                pw.Text(
                  'Payment Terms: ${_receiptData["paymentTerms"]}',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'QR Code: ${_receiptData["qrCode"]}',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'This is an official receipt generated by the Barangay Water Utility Management System.',
                  style:
                      pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
                ),
              ],
            );
          },
        ),
      );

      await _downloadPDF(pdf);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF receipt generated successfully'),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _downloadPDF(pw.Document pdf) async {
    final bytes = await pdf.save();
    final filename =
        'Receipt_${_receiptData["receiptNumber"]}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(bytes);
    }
  }

  Future<void> _sendSMS() async {
    if (!_validateFields()) {
      setState(() {});
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final message = '''
Water Utility Bill - ${_receiptData["barangayName"]}

Dear ${_receiptData["homeownerName"]},

Your water bill for ${_receiptData["billingPeriod"]} is ready.

Amount Due: ₱${_receiptData["totalAmount"]}
Due Date: ${_receiptData["dueDate"]}
Meter: ${_receiptData["meterNumber"]}

Please settle your payment on or before the due date to avoid penalties.

Thank you!
      '''
          .trim();

      // Simulate SMS sending with platform-specific implementation
      if (kIsWeb) {
        // Web: Open SMS in new tab/window
        final encodedMessage = Uri.encodeComponent(message);
        final smsUrl =
            'sms:${_receiptData["homeownerPhone"]}?body=$encodedMessage';
        html.window.open(smsUrl, '_blank');
      } else {
        // Mobile: Use platform channel to send SMS
        const platform = MethodChannel('com.barangay.meter_reader/sms');
        await platform.invokeMethod('sendSMS', {
          'phone': _receiptData["homeownerPhone"],
          'message': message,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('SMS notification sent successfully'),
            backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending SMS: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _sendEmail() async {
    if (!_validateFields()) {
      setState(() {});
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final subject =
          'Water Utility Bill - ${_receiptData["barangayName"]} - ${_receiptData["billingPeriod"]}';
      final body = '''
Dear ${_receiptData["homeownerName"]},

We hope this email finds you well. Please find attached your water utility bill for ${_receiptData["billingPeriod"]}.

BILLING DETAILS:
- Receipt Number: ${_receiptData["receiptNumber"]}
- Billing Period: ${_receiptData["billingPeriod"]}
- Meter Number: ${_receiptData["meterNumber"]}
- Consumption: ${_receiptData["consumption"]} cubic meters
- Amount Due: ₱${_receiptData["totalAmount"]}
- Due Date: ${_receiptData["dueDate"]}

PAYMENT TERMS:
${_receiptData["paymentTerms"]}

Please settle your payment on or before the due date to avoid additional charges.

If you have any questions or concerns regarding this bill, please don't hesitate to contact our office.

Thank you for your prompt attention to this matter.

Best regards,
Barangay ${_receiptData["barangayName"]} Water Utility Office
      '''
          .trim();

      // Generate PDF for email attachment
      final pdf = pw.Document();
      // Add PDF content (similar to _generatePDF but for attachment)
      final pdfBytes = await pdf.save();

      if (kIsWeb) {
        // Web: Open email client with pre-filled content
        final encodedSubject = Uri.encodeComponent(subject);
        final encodedBody = Uri.encodeComponent(body);
        final mailtoUrl =
            'mailto:${_receiptData["homeownerEmail"]}?subject=$encodedSubject&body=$encodedBody';
        html.window.open(mailtoUrl, '_blank');
      } else {
        // Mobile: Use platform channel to send email with attachment
        const platform = MethodChannel('com.barangay.meter_reader/email');
        await platform.invokeMethod('sendEmail', {
          'to': _receiptData["homeownerEmail"],
          'subject': subject,
          'body': body,
          'attachment': pdfBytes,
          'attachmentName': 'Receipt_${_receiptData["receiptNumber"]}.pdf',
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email sent successfully'),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending email: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _printReceipt() async {
    if (!_validateFields()) {
      setState(() {});
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BARANGAY ${(_receiptData["barangayName"] as String).toUpperCase()}',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('Water Utility Billing Receipt'),
                pw.SizedBox(height: 10),
                pw.Text('Receipt #: ${_receiptData["receiptNumber"]}'),
                pw.Text('Date: ${_receiptData["issueDate"]}'),
                pw.SizedBox(height: 10),
                pw.Text('Homeowner: ${_receiptData["homeownerName"]}'),
                pw.Text('Address: ${_receiptData["address"]}'),
                pw.Text('Meter: ${_receiptData["meterNumber"]}'),
                pw.SizedBox(height: 10),
                pw.Text('Billing Period: ${_receiptData["billingPeriod"]}'),
                pw.Text('Consumption: ${_receiptData["consumption"]} cu.m'),
                pw.Text('Rate: ₱${_receiptData["ratePerCubicMeter"]}/cu.m'),
                pw.Text('Basic Charge: ₱${_receiptData["basicCharge"]}'),
                if (parseDouble(_receiptData["penalties"]) > 0)
                  pw.Text('Penalties: ₱${_receiptData["penalties"]}'),
                pw.Divider(),
                pw.Text(
                  'TOTAL: ₱${_receiptData["totalAmount"]}',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('Due Date: ${_receiptData["dueDate"]}'),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Receipt sent to printer'),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing receipt: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          title: Text(
            'Billing Receipt Generation',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
          elevation: 2,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
      );
    }

    // If loading finished but no receipt data is available, show retry UI
    if (_receiptData.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          title: Text(
            'Billing Receipt Generation',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
          elevation: 2,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load billing data.',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _fetchBillingData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Billing Receipt Generation',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            icon: CustomIconWidget(
              iconName: _isEditing ? 'visibility' : 'edit',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 6.w,
            ),
            tooltip: _isEditing ? 'Preview Mode' : 'Edit Mode',
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/reading-history');
            },
            icon: CustomIconWidget(
              iconName: 'history',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 6.w,
            ),
            tooltip: 'View History',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_isEditing)
                      EditableFieldsWidget(
                        receiptData: _receiptData,
                        onFieldChanged: _onFieldChanged,
                        validationErrors: _validationErrors,
                      )
                    else
                      ReceiptPreviewWidget(
                        receiptData: _receiptData,
                        isEditing: _isEditing,
                      ),
                    SizedBox(height: 20.h), // Space for bottom sheet
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: CommunicationOptionsWidget(
        receiptData: _receiptData,
        onGeneratePDF: _generatePDF,
        onSendSMS: _sendSMS,
        onSendEmail: _sendEmail,
        onPrintReceipt: _printReceipt,
        isProcessing: _isProcessing,
      ),
    );
  }
}
