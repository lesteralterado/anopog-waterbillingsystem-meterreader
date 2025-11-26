import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/user_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/batch_operations_toolbar_widget.dart';
import './widgets/bulk_actions_fab_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/homeowner_card_widget.dart';
import './widgets/search_filter_bar_widget.dart';

class MeterReadingList extends StatefulWidget {
  const MeterReadingList({super.key});

  @override
  State<MeterReadingList> createState() => _MeterReadingListState();
}

class _MeterReadingListState extends State<MeterReadingList> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final UserService _userService = UserService();

  List<Map<String, dynamic>> _allHomeowners = [];
  List<Map<String, dynamic>> _filteredHomeowners = [];
  Map<String, dynamic> _activeFilters = {};
  List<String> _activeFilterLabels = [];
  Set<int> _selectedHomeowners = {};
  bool _isMultiSelectMode = false;
  bool _isLoading = false;
  bool _isOfflineMode = false;
  int _syncPendingCount = 3;
  String? _selectedPurok;

  @override
  void initState() {
    super.initState();
    debugPrint('MeterReadingList initState called');

    // Get purok and consumers from route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      debugPrint('MeterReadingList received args: $args');

      if (args != null) {
        _selectedPurok = args['purok']?['name'] as String?;
        final consumers = args['consumers'] as List<Map<String, dynamic>>?;
        debugPrint('Selected purok: $_selectedPurok');
        debugPrint('Consumers received: ${consumers?.length ?? 0} items');

        if (consumers != null && consumers.isNotEmpty) {
          debugPrint('Loading data from args...');
          setState(() => _isLoading = true); // Show loading while processing
          _loadHomeownerDataFromArgs(consumers);
        } else {
          debugPrint('No consumers provided, loading default data');
          _loadHomeownerData();
        }
      } else {
        debugPrint('No args provided, loading default data');
        _loadHomeownerData();
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHomeownerData() async {
    setState(() => _isLoading = true);

    try {
      final consumers = await _userService.fetchConsumers();

      // Filter by purok if one is selected
      List<Map<String, dynamic>> filteredConsumers = consumers;
      if (_selectedPurok != null) {
        filteredConsumers = consumers.where((consumer) {
          final consumerPurok = consumer['purok'] as String?;
          return consumerPurok == _selectedPurok;
        }).toList();
      }

      // Convert consumer data to homeowner format expected by the UI
      _allHomeowners = filteredConsumers.map((consumer) {
        final purok = consumer['purok'] as String? ?? 'Unknown';
        final meterNumber = consumer['meter_number'] as String? ?? 'N/A';
        final fullName = consumer['full_name'] as String? ?? 'Unknown';
        final address = consumer['address'] as String? ?? 'No address';
        final phone = consumer['phone'] as String? ?? 'No phone';

        return {
          "id": consumer['id'] as int? ?? 0,
          "houseNumber": meterNumber, // Use meter number as house number
          "name": fullName,
          "address": "$address, $purok",
          "previousReading": 0.0, // Default values for meter reading fields
          "dueDate": "N/A",
          "status": "pending",
          "meterNumber": meterNumber,
          "phoneNumber": phone,
          "paymentStatus": "unpaid",
          "street": purok, // Use purok as street
          "lastReadingDate": DateTime.now().subtract(const Duration(days: 30)),
        };
      }).toList();

      _filteredHomeowners = List.from(_allHomeowners);
    } catch (e) {
      debugPrint('Error loading consumers: $e');
      // Fallback to empty list
      _allHomeowners = [];
      _filteredHomeowners = [];
    }

    setState(() => _isLoading = false);
  }

  void _loadHomeownerDataFromArgs(List<Map<String, dynamic>> consumers) {
    debugPrint('Converting ${consumers.length} consumers to homeowners format');
    debugPrint(
        'First consumer sample: ${consumers.isNotEmpty ? consumers.first : 'No consumers'}');

    // Convert consumer data to homeowner format expected by the UI
    _allHomeowners = consumers.map((consumer) {
      final purok = consumer['purok'] as String? ?? 'Unknown';
      final meterNumber = consumer['meter_number'] as String? ?? 'N/A';
      final username = consumer['username'] as String? ?? 'Unknown';
      final fullName = consumer['full_name'] as String?;
      final address = consumer['address'] as String? ?? 'No address';
      final phone = consumer['phone'] as String? ?? 'No phone';

      // Use username as fallback if full_name is null
      final displayName = fullName ?? username;

      // Convert string ID to int, handling both string and int inputs
      final consumerId = consumer['id'];
      final int homeownerId = consumerId is String
          ? int.tryParse(consumerId) ?? 0
          : (consumerId as int?) ?? 0;

      final homeowner = {
        "id": homeownerId,
        "name": displayName,
        "address": "$address, Purok $purok",
        "accountNumber":
            meterNumber, // Map meter number to account number for meter reading screen
        "previousReading": 0.0, // Default values for meter reading fields
        "lastReadingDate": DateTime.now().subtract(const Duration(days: 30)),
        "meterType": "Digital Water Meter",
        "connectionStatus": "Active",
        // Additional fields for consumer list display
        "houseNumber": meterNumber,
        "dueDate": "N/A",
        "status": "pending",
        "meterNumber": meterNumber,
        "phoneNumber": phone,
        "paymentStatus": "unpaid",
        "street": "Purok $purok",
      };

      return homeowner;
    }).toList();

    _filteredHomeowners = List.from(_allHomeowners);
    debugPrint('Converted to ${_allHomeowners.length} homeowners');
    debugPrint(
        'First homeowner sample: ${_allHomeowners.isNotEmpty ? _allHomeowners.first : 'No homeowners'}');

    // Update loading state and force UI update
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    // Temporarily disable filtering to debug
    _activeFilters.clear();
    _activeFilterLabels.clear();
    _searchController.clear();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredHomeowners = _allHomeowners.where((homeowner) {
        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        if (searchQuery.isNotEmpty) {
          final name = (homeowner['name'] as String? ?? '').toLowerCase();
          final address = (homeowner['address'] as String? ?? '').toLowerCase();
          final meterNumber =
              (homeowner['meterNumber'] as String? ?? '').toLowerCase();

          if (!name.contains(searchQuery) &&
              !address.contains(searchQuery) &&
              !meterNumber.contains(searchQuery)) {
            return false;
          }
        }

        // Status filter
        final statusFilter = _activeFilters['status'] as String?;
        if (statusFilter != null && statusFilter != 'All') {
          if ((homeowner['status'] as String? ?? '').toLowerCase() !=
              statusFilter.toLowerCase()) {
            return false;
          }
        }

        // Street filter
        final streetFilter = _activeFilters['street'] as String?;
        if (streetFilter != null && streetFilter != 'All') {
          if ((homeowner['street'] as String? ?? '') != streetFilter) {
            return false;
          }
        }

        // Payment status filter
        final paymentStatusFilter = _activeFilters['paymentStatus'] as String?;
        if (paymentStatusFilter != null && paymentStatusFilter != 'All') {
          if ((homeowner['paymentStatus'] as String? ?? '').toLowerCase() !=
              paymentStatusFilter.toLowerCase()) {
            return false;
          }
        }

        // Date range filter
        final startDate = _activeFilters['startDate'] as DateTime?;
        final endDate = _activeFilters['endDate'] as DateTime?;
        final lastReadingDate = homeowner['lastReadingDate'] as DateTime?;

        if (startDate != null && lastReadingDate != null) {
          if (lastReadingDate.isBefore(startDate)) return false;
        }

        if (endDate != null && lastReadingDate != null) {
          if (lastReadingDate.isAfter(endDate)) return false;
        }

        return true;
      }).toList();
    });

    _updateActiveFilterLabels();
  }

  void _updateActiveFilterLabels() {
    _activeFilterLabels.clear();

    final status = _activeFilters['status'] as String?;
    if (status != null && status != 'All') {
      _activeFilterLabels.add('Status: $status');
    }

    final street = _activeFilters['street'] as String?;
    if (street != null && street != 'All') {
      _activeFilterLabels.add('Street: $street');
    }

    final paymentStatus = _activeFilters['paymentStatus'] as String?;
    if (paymentStatus != null && paymentStatus != 'All') {
      _activeFilterLabels.add('Payment: $paymentStatus');
    }

    final startDate = _activeFilters['startDate'] as DateTime?;
    final endDate = _activeFilters['endDate'] as DateTime?;
    if (startDate != null || endDate != null) {
      String dateLabel = 'Date: ';
      if (startDate != null) {
        dateLabel += '${startDate.day}/${startDate.month}/${startDate.year}';
      }
      if (endDate != null) {
        if (startDate != null) dateLabel += ' - ';
        dateLabel += '${endDate.day}/${endDate.month}/${endDate.year}';
      }
      _activeFilterLabels.add(dateLabel);
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: 80.h,
        child: FilterBottomSheetWidget(
          currentFilters: _activeFilters,
          onFiltersChanged: (filters) {
            setState(() {
              _activeFilters = filters;
            });
            _applyFilters();
          },
        ),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
      _activeFilterLabels.clear();
      _searchController.clear();
    });
    _applyFilters();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    _loadHomeownerData();

    Fluttertoast.showToast(
      msg: "Data refreshed successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedHomeowners.clear();
      }
    });
  }

  void _toggleHomeownerSelection(int id) {
    setState(() {
      if (_selectedHomeowners.contains(id)) {
        _selectedHomeowners.remove(id);
      } else {
        _selectedHomeowners.add(id);
      }
    });
  }

  void _selectAllHomeowners() {
    setState(() {
      _selectedHomeowners =
          _filteredHomeowners.map((h) => h['id'] as int).toSet();
    });
  }

  void _deselectAllHomeowners() {
    setState(() {
      _selectedHomeowners.clear();
    });
  }

  void _markSelectedAsComplete() {
    if (_selectedHomeowners.isEmpty) return;

    setState(() {
      for (final homeowner in _allHomeowners) {
        if (_selectedHomeowners.contains(homeowner['id'])) {
          homeowner['status'] = 'completed';
        }
      }
      _selectedHomeowners.clear();
      _isMultiSelectMode = false;
    });

    _applyFilters();

    Fluttertoast.showToast(
      msg: "Selected readings marked as complete",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _markSelectedAsIssue() {
    if (_selectedHomeowners.isEmpty) return;

    setState(() {
      for (final homeowner in _allHomeowners) {
        if (_selectedHomeowners.contains(homeowner['id'])) {
          homeowner['status'] = 'issue';
        }
      }
      _selectedHomeowners.clear();
      _isMultiSelectMode = false;
    });

    _applyFilters();

    Fluttertoast.showToast(
      msg: "Selected readings marked as issue",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _exportSelectedData() {
    final selectedData = _filteredHomeowners
        .where((h) =>
            _selectedHomeowners.isEmpty ||
            _selectedHomeowners.contains(h['id']))
        .toList();

    // Simulate export functionality
    Fluttertoast.showToast(
      msg: "Exported ${selectedData.length} records",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _callHomeowner(Map<String, dynamic> homeowner) {
    final phoneNumber = homeowner['phoneNumber'] as String? ?? '';
    Fluttertoast.showToast(
      msg: "Calling $phoneNumber",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _viewHomeownerHistory(Map<String, dynamic> homeowner) {
    Navigator.pushNamed(context, '/reading-history');
  }

  void _markHomeownerIssue(Map<String, dynamic> homeowner) {
    setState(() {
      homeowner['status'] = 'issue';
    });
    _applyFilters();

    Fluttertoast.showToast(
      msg: "Marked ${homeowner['name']} as issue",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _skipHomeownerReading(Map<String, dynamic> homeowner) {
    _showSkipReasonDialog(homeowner);
  }

  void _showSkipReasonDialog(Map<String, dynamic> homeowner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Skip Reading'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select reason for skipping ${homeowner['name']}\'s reading:'),
            SizedBox(height: 2.h),
            ...['No one home', 'Meter inaccessible', 'Meter damaged', 'Other']
                .map(
              (reason) => ListTile(
                title: Text(reason),
                onTap: () {
                  Navigator.pop(context);
                  Fluttertoast.showToast(
                    msg: "Skipped reading: $reason",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _openMeterReadingEntry(Map<String, dynamic> homeowner) {
    debugPrint('Opening meter reading entry for homeowner: $homeowner');
    debugPrint('Homeowner ID: ${homeowner['id']}');
    debugPrint('Homeowner name: ${homeowner['name']}');

    Navigator.pushNamed(context, '/meter-reading-entry', arguments: homeowner);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedPurok != null
                  ? '$_selectedPurok Consumers (${_allHomeowners.length})'
                  : 'Meter Reading List',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimary,
              ),
            ),
            if (_isOfflineMode)
              Text(
                'Offline Mode • $_syncPendingCount pending',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        leading: IconButton(
          onPressed: () =>
              Navigator.pushNamed(context, '/purok-selection-dashboard'),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: colorScheme.onPrimary,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          SearchFilterBarWidget(
            searchController: _searchController,
            onSearchChanged: (String value) => _onSearchChanged(),
            activeFilters: _activeFilterLabels,
            onFilterPressed: _showFilterBottomSheet,
            onClearFilters: _clearAllFilters,
          ),

          // Homeowner List
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  )
                : _filteredHomeowners.isEmpty
                    ? _buildEmptyState(context, theme, colorScheme)
                    : RefreshIndicator(
                        onRefresh: _refreshData,
                        color: colorScheme.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _filteredHomeowners.length,
                          itemBuilder: (context, index) {
                            final homeowner = _filteredHomeowners[index];
                            final homeownerId = homeowner['id'] as int;
                            final isSelected =
                                _selectedHomeowners.contains(homeownerId);

                            return HomeownerCardWidget(
                              homeowner: homeowner,
                              isSelected: _isMultiSelectMode && isSelected,
                              onTap: _isMultiSelectMode
                                  ? () => _toggleHomeownerSelection(homeownerId)
                                  : () => _openMeterReadingEntry(homeowner),
                              onLongPress: _isMultiSelectMode
                                  ? null
                                  : () {
                                      setState(() => _isMultiSelectMode = true);
                                      _toggleHomeownerSelection(homeownerId);
                                    },
                              onCall: () => _callHomeowner(homeowner),
                              onViewHistory: () =>
                                  _viewHomeownerHistory(homeowner),
                              onMarkIssue: () => _markHomeownerIssue(homeowner),
                              onSkipReading: () =>
                                  _skipHomeownerReading(homeowner),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: BulkActionsFabWidget(
        isMultiSelectMode: _isMultiSelectMode,
        selectedCount: _selectedHomeowners.length,
        onExportList: _exportSelectedData,
        onMarkMultipleComplete: _markSelectedAsComplete,
        onToggleMultiSelect: _toggleMultiSelectMode,
      ),
      bottomNavigationBar: _isMultiSelectMode
          ? BatchOperationsToolbarWidget(
              selectedCount: _selectedHomeowners.length,
              isAllSelected:
                  _selectedHomeowners.length == _filteredHomeowners.length,
              onSelectAll: _selectAllHomeowners,
              onDeselectAll: _deselectAllHomeowners,
              onMarkComplete: _markSelectedAsComplete,
              onMarkIssue: _markSelectedAsIssue,
              onExport: _exportSelectedData,
              onCancel: _toggleMultiSelectMode,
            )
          : null,
    );
  }

  Widget _buildEmptyState(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'No homeowners found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _searchController.text.isNotEmpty ||
                      _activeFilterLabels.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : _selectedPurok != null
                      ? 'No consumers found in $_selectedPurok'
                      : 'No consumer records available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchController.text.isNotEmpty ||
                _activeFilterLabels.isNotEmpty) ...[
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: _clearAllFilters,
                child: Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
