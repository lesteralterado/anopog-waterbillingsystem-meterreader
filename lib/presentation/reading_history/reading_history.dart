import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_tab_bar.dart';
import './widgets/advanced_filter_bottom_sheet.dart';
import './widgets/export_options_bottom_sheet.dart';
import './widgets/history_filter_chips.dart';
import './widgets/history_search_bar.dart';
import './widgets/history_statistics_card.dart';
import './widgets/reading_history_card.dart';

class ReadingHistory extends StatefulWidget {
  const ReadingHistory({super.key});

  @override
  State<ReadingHistory> createState() => _ReadingHistoryState();
}

class _ReadingHistoryState extends State<ReadingHistory>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All Readings';
  String _searchQuery = '';
  Map<String, dynamic> _advancedFilters = {};
  List<String> _selectedReadingIds = [];
  bool _isMultiSelectMode = false;
  bool _isLoading = false;

  // Mock data for reading history
  final List<Map<String, dynamic>> _allReadings = [
    {
      "id": "RH001",
      "homeownerName": "Maria Santos",
      "address": "123 Sampaguita St., Purok 1",
      "purok": "Purok 1",
      "readingDate": "01/15/2025",
      "consumption": 25.5,
      "billingAmount": 1275.00,
      "status": "paid",
      "meterPhoto":
          "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop",
      "gpsCoordinates": "14.5995° N, 120.9842° E",
      "readingValue": 1025.5,
      "previousReading": 1000.0,
      "dateCreated": DateTime(2025, 1, 15),
    },
    {
      "id": "RH002",
      "homeownerName": "Juan Dela Cruz",
      "address": "456 Rose Ave., Purok 2",
      "purok": "Purok 2",
      "readingDate": "01/14/2025",
      "consumption": 18.3,
      "billingAmount": 915.00,
      "status": "sent",
      "meterPhoto":
          "https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?w=400&h=400&fit=crop",
      "gpsCoordinates": "14.6010° N, 120.9850° E",
      "readingValue": 875.3,
      "previousReading": 857.0,
      "dateCreated": DateTime(2025, 1, 14),
    },
    {
      "id": "RH003",
      "homeownerName": "Ana Rodriguez",
      "address": "789 Lily Lane, Purok 3",
      "purok": "Purok 3",
      "readingDate": "01/13/2025",
      "consumption": 32.1,
      "billingAmount": 1605.00,
      "status": "pending billing",
      "meterPhoto":
          "https://images.unsplash.com/photo-1581092918484-8313a4b6e0c2?w=400&h=400&fit=crop",
      "gpsCoordinates": "14.5980° N, 120.9835° E",
      "readingValue": 1156.1,
      "previousReading": 1124.0,
      "dateCreated": DateTime(2025, 1, 13),
    },
    {
      "id": "RH004",
      "homeownerName": "Roberto Garcia",
      "address": "321 Sunflower St., Purok 4",
      "purok": "Purok 4",
      "readingDate": "01/12/2025",
      "consumption": 22.8,
      "billingAmount": 1140.00,
      "status": "completed",
      "meterPhoto":
          "https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?w=400&h=400&fit=crop",
      "gpsCoordinates": "14.6005° N, 120.9845° E",
      "readingValue": 945.8,
      "previousReading": 923.0,
      "dateCreated": DateTime(2025, 1, 12),
    },
    {
      "id": "RH005",
      "homeownerName": "Carmen Lopez",
      "address": "654 Orchid Blvd., Purok 5",
      "purok": "Purok 5",
      "readingDate": "01/11/2025",
      "consumption": 28.7,
      "billingAmount": 1435.00,
      "status": "paid",
      "meterPhoto":
          "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop",
      "gpsCoordinates": "14.5990° N, 120.9840° E",
      "readingValue": 1089.7,
      "previousReading": 1061.0,
      "dateCreated": DateTime(2025, 1, 11),
    },
    {
      "id": "RH006",
      "homeownerName": "Pedro Reyes",
      "address": "987 Jasmine Dr., Purok 6",
      "purok": "Purok 6",
      "readingDate": "01/10/2025",
      "consumption": 15.2,
      "billingAmount": 760.00,
      "status": "sent",
      "meterPhoto":
          "https://images.unsplash.com/photo-1581092918484-8313a4b6e0c2?w=400&h=400&fit=crop",
      "gpsCoordinates": "14.6015° N, 120.9855° E",
      "readingValue": 678.2,
      "previousReading": 663.0,
      "dateCreated": DateTime(2025, 1, 10),
    },
    {
      "id": "RH007",
      "homeownerName": "Lisa Fernandez",
      "address": "147 Dahlia St., Purok 7",
      "purok": "Purok 7",
      "readingDate": "01/09/2025",
      "consumption": 35.4,
      "billingAmount": 1770.00,
      "status": "completed",
      "meterPhoto":
          "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop",
      "gpsCoordinates": "14.5985° N, 120.9830° E",
      "readingValue": 1234.4,
      "previousReading": 1199.0,
      "dateCreated": DateTime(2025, 1, 9),
    },
    {
      "id": "RH008",
      "homeownerName": "Miguel Torres",
      "address": "258 Tulip Ave., Purok 8",
      "purok": "Purok 8",
      "readingDate": "01/08/2025",
      "consumption": 19.6,
      "billingAmount": 980.00,
      "status": "pending billing",
      "meterPhoto":
          "https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?w=400&h=400&fit=crop",
      "gpsCoordinates": "14.6000° N, 120.9848° E",
      "readingValue": 789.6,
      "previousReading": 770.0,
      "dateCreated": DateTime(2025, 1, 8),
    },
  ];

  List<Map<String, dynamic>> _filteredReadings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 4);
    _filteredReadings = List.from(_allReadings);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allReadings);

    // Apply time-based filter
    if (_selectedFilter != 'All Readings') {
      final now = DateTime.now();
      DateTime filterDate;

      switch (_selectedFilter) {
        case 'Today':
          filterDate = DateTime(now.year, now.month, now.day);
          filtered = filtered.where((reading) {
            final readingDate = reading['dateCreated'] as DateTime;
            return readingDate.isAfter(filterDate.subtract(Duration(days: 1)));
          }).toList();
          break;
        case 'This Week':
          filterDate = now.subtract(Duration(days: 7));
          filtered = filtered.where((reading) {
            final readingDate = reading['dateCreated'] as DateTime;
            return readingDate.isAfter(filterDate);
          }).toList();
          break;
        case 'This Month':
          filterDate = DateTime(now.year, now.month, 1);
          filtered = filtered.where((reading) {
            final readingDate = reading['dateCreated'] as DateTime;
            return readingDate.isAfter(filterDate.subtract(Duration(days: 1)));
          }).toList();
          break;
      }
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((reading) {
        final homeownerName =
            (reading['homeownerName'] as String? ?? '').toLowerCase();
        final address = (reading['address'] as String? ?? '').toLowerCase();
        final purok = (reading['purok'] as String? ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();

        return homeownerName.contains(query) ||
            address.contains(query) ||
            purok.contains(query);
      }).toList();
    }

    // Apply advanced filters
    if (_advancedFilters.isNotEmpty) {
      if (_advancedFilters['selectedPurok'] != null &&
          _advancedFilters['selectedPurok'] != 'All Puroks') {
        filtered = filtered
            .where((reading) =>
                reading['purok'] == _advancedFilters['selectedPurok'])
            .toList();
      }

      if (_advancedFilters['selectedStatus'] != null &&
          _advancedFilters['selectedStatus'] != 'All Status') {
        filtered = filtered
            .where((reading) =>
                (reading['status'] as String).toLowerCase() ==
                (_advancedFilters['selectedStatus'] as String).toLowerCase())
            .toList();
      }

      if (_advancedFilters['minReading'] != null) {
        filtered = filtered
            .where((reading) =>
                (reading['consumption'] as double) >=
                (_advancedFilters['minReading'] as double))
            .toList();
      }

      if (_advancedFilters['maxReading'] != null) {
        filtered = filtered
            .where((reading) =>
                (reading['consumption'] as double) <=
                (_advancedFilters['maxReading'] as double))
            .toList();
      }

      if (_advancedFilters['startDate'] != null) {
        filtered = filtered
            .where((reading) => (reading['dateCreated'] as DateTime)
                .isAfter(_advancedFilters['startDate']))
            .toList();
      }

      if (_advancedFilters['endDate'] != null) {
        filtered = filtered
            .where((reading) => (reading['dateCreated'] as DateTime)
                .isBefore(_advancedFilters['endDate']))
            .toList();
      }
    }

    setState(() {
      _filteredReadings = filtered;
    });
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFilterBottomSheet(
        currentFilters: _advancedFilters,
        onFiltersApplied: (filters) {
          setState(() {
            _advancedFilters = filters;
            _applyFilters();
          });
        },
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportOptionsBottomSheet(
        onExport: _exportData,
      ),
    );
  }

  Future<void> _exportData(
      String format, DateTime? startDate, DateTime? endDate) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> dataToExport = _filteredReadings;

      if (startDate != null || endDate != null) {
        dataToExport = _filteredReadings.where((reading) {
          final readingDate = reading['dateCreated'] as DateTime;
          if (startDate != null && readingDate.isBefore(startDate))
            return false;
          if (endDate != null && readingDate.isAfter(endDate)) return false;
          return true;
        }).toList();
      }

      if (format == 'CSV') {
        await _exportToCSV(dataToExport);
      } else if (format == 'PDF') {
        await _exportToPDF(dataToExport);
      }

      Fluttertoast.showToast(
        msg: '$format export completed successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Export failed. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportToCSV(List<Map<String, dynamic>> data) async {
    final csvContent = StringBuffer();

    // CSV Header
    csvContent.writeln(
        'ID,Homeowner Name,Address,Purok,Reading Date,Consumption (m³),Billing Amount (₱),Status,GPS Coordinates');

    // CSV Data
    for (final reading in data) {
      csvContent.writeln([
        reading['id'],
        reading['homeownerName'],
        reading['address'],
        reading['purok'],
        reading['readingDate'],
        reading['consumption'],
        reading['billingAmount'],
        reading['status'],
        reading['gpsCoordinates'],
      ]
          .map((field) => '"${field.toString().replaceAll('"', '""')}"')
          .join(','));
    }

    final filename =
        'reading_history_${DateTime.now().millisecondsSinceEpoch}.csv';

    if (kIsWeb) {
      final bytes = utf8.encode(csvContent.toString());
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(csvContent.toString());
    }
  }

  Future<void> _exportToPDF(List<Map<String, dynamic>> data) async {
    // For PDF export, we'll create a simple text-based PDF content
    final pdfContent = StringBuffer();

    pdfContent.writeln('BARANGAY METER READING HISTORY REPORT');
    pdfContent
        .writeln('Generated on: ${DateTime.now().toString().split('.')[0]}');
    pdfContent.writeln('Total Records: ${data.length}');
    pdfContent.writeln('=' * 80);
    pdfContent.writeln();

    for (final reading in data) {
      pdfContent.writeln('ID: ${reading['id']}');
      pdfContent.writeln('Homeowner: ${reading['homeownerName']}');
      pdfContent.writeln('Address: ${reading['address']}');
      pdfContent.writeln('Reading Date: ${reading['readingDate']}');
      pdfContent.writeln('Consumption: ${reading['consumption']} m³');
      pdfContent.writeln('Billing Amount: ₱${reading['billingAmount']}');
      pdfContent.writeln('Status: ${reading['status']}');
      pdfContent.writeln('-' * 40);
    }

    final filename =
        'reading_history_${DateTime.now().millisecondsSinceEpoch}.txt';

    if (kIsWeb) {
      final bytes = utf8.encode(pdfContent.toString());
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(pdfContent.toString());
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate data refresh
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    Fluttertoast.showToast(
      msg: 'Data refreshed successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _toggleMultiSelect() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedReadingIds.clear();
      }
    });
  }

  void _toggleReadingSelection(String readingId) {
    setState(() {
      if (_selectedReadingIds.contains(readingId)) {
        _selectedReadingIds.remove(readingId);
      } else {
        _selectedReadingIds.add(readingId);
      }
    });
  }

  void _performBulkAction(String action) {
    if (_selectedReadingIds.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please select readings first',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    switch (action) {
      case 'export':
        _showExportOptions();
        break;
      case 'resend':
        Fluttertoast.showToast(
          msg:
              'Resending notifications for ${_selectedReadingIds.length} readings',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        break;
      case 'update_status':
        Fluttertoast.showToast(
          msg: 'Status updated for ${_selectedReadingIds.length} readings',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        break;
    }

    setState(() {
      _isMultiSelectMode = false;
      _selectedReadingIds.clear();
    });
  }

  double get _averageConsumption {
    if (_filteredReadings.isEmpty) return 0.0;
    final total = _filteredReadings.fold<double>(0.0,
        (sum, reading) => sum + (reading['consumption'] as double? ?? 0.0));
    return total / _filteredReadings.length;
  }

  double get _collectionEfficiency {
    if (_filteredReadings.isEmpty) return 0.0;
    final paidReadings = _filteredReadings
        .where(
            (reading) => (reading['status'] as String).toLowerCase() == 'paid')
        .length;
    return (paidReadings / _filteredReadings.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Reading History',
        variant: CustomAppBarVariant.withActions,
        actions: [
          if (_isMultiSelectMode) ...[
            IconButton(
              onPressed: () => _performBulkAction('export'),
              icon: CustomIconWidget(
                iconName: 'file_download',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
            ),
            IconButton(
              onPressed: () => _performBulkAction('resend'),
              icon: CustomIconWidget(
                iconName: 'send',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
            ),
            IconButton(
              onPressed: _toggleMultiSelect,
              icon: CustomIconWidget(
                iconName: 'close',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
            ),
          ] else ...[
            IconButton(
              onPressed: _showExportOptions,
              icon: CustomIconWidget(
                iconName: 'file_download',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
            ),
            PopupMenuButton<String>(
              icon: CustomIconWidget(
                iconName: 'more_vert',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'multi_select':
                    _toggleMultiSelect();
                    break;
                  case 'refresh':
                    _refreshData();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'multi_select',
                  child: Row(
                    children: [
                      Icon(Icons.checklist),
                      SizedBox(width: 8),
                      Text('Multi Select'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Refresh'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          CustomTabBar(
            controller: _tabController,
            tabs: const [
              'Dashboard',
              'Readings',
              'Add Entry',
              'Billing',
              'History'
            ],
            variant: CustomTabBarVariant.scrollable,
          ),
          HistorySearchBar(
            controller: _searchController,
            onChanged: (value) => _onSearchChanged(),
            onFilterPressed: _showAdvancedFilters,
          ),
          HistoryFilterChips(
            selectedFilter: _selectedFilter,
            onFilterChanged: _onFilterChanged,
          ),
          HistoryStatisticsCard(
            totalReadings: _filteredReadings.length,
            averageConsumption: _averageConsumption,
            collectionEfficiency: _collectionEfficiency,
            selectedPeriod: _selectedFilter,
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  )
                : _filteredReadings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'history',
                              size: 64,
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'No reading history found',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Try adjusting your filters or search terms',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshData,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        child: ListView.builder(
                          padding: EdgeInsets.only(bottom: 2.h),
                          itemCount: _filteredReadings.length,
                          itemBuilder: (context, index) {
                            final reading = _filteredReadings[index];
                            final readingId = reading['id'] as String;
                            final isSelected =
                                _selectedReadingIds.contains(readingId);

                            return ReadingHistoryCard(
                              reading: reading,
                              isSelected: isSelected,
                              onTap: _isMultiSelectMode
                                  ? () => _toggleReadingSelection(readingId)
                                  : null,
                              onLongPress: () {
                                if (!_isMultiSelectMode) {
                                  _toggleMultiSelect();
                                  _toggleReadingSelection(readingId);
                                }
                              },
                              onRegenerateReceipt: () {
                                Fluttertoast.showToast(
                                  msg:
                                      'Regenerating receipt for ${reading['homeownerName']}',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              },
                              onResendNotification: () {
                                Fluttertoast.showToast(
                                  msg:
                                      'Resending notification to ${reading['homeownerName']}',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              },
                              onEditReading: () {
                                Navigator.pushNamed(
                                    context, '/meter-reading-entry');
                              },
                              onViewDetails: () {
                                Navigator.pushNamed(
                                    context, '/billing-receipt-generation');
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 4,
        onTap: (index) {
          final routes = [
            '/purok-selection-dashboard',
            '/meter-reading-list',
            '/meter-reading-entry',
            '/billing-receipt-generation',
            '/reading-history',
          ];

          if (index != 4 && index < routes.length) {
            Navigator.pushNamed(context, routes[index]);
          }
        },
      ),
    );
  }
}
