import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/dashboard_header_widget.dart';
import './widgets/progress_banner_widget.dart';
import './widgets/purok_card_widget.dart';
import './widgets/quick_actions_modal_widget.dart';
import './widgets/route_optimization_modal_widget.dart';

class PurokSelectionDashboard extends StatefulWidget {
  const PurokSelectionDashboard({super.key});

  @override
  State<PurokSelectionDashboard> createState() =>
      _PurokSelectionDashboardState();
}

class _PurokSelectionDashboardState extends State<PurokSelectionDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isSynced = true;
  bool _isRefreshing = false;

  // Mock data for puroks
  final List<Map<String, dynamic>> _purokData = [
    {
      "id": 1,
      "name": "Purok 1 - Maligaya",
      "totalMeters": 45,
      "completedMeters": 45,
      "completionPercentage": 100,
      "status": "completed",
      "lastReadingDate": "Dec 04, 2025",
      "estimatedTime": 35,
    },
    {
      "id": 2,
      "name": "Purok 2 - Masaya",
      "totalMeters": 38,
      "completedMeters": 28,
      "completionPercentage": 74,
      "status": "in_progress",
      "lastReadingDate": "Dec 03, 2025",
      "estimatedTime": 25,
    },
    {
      "id": 3,
      "name": "Purok 3 - Maunlad",
      "totalMeters": 52,
      "completedMeters": 15,
      "completionPercentage": 29,
      "status": "overdue",
      "lastReadingDate": "Nov 28, 2025",
      "estimatedTime": 45,
    },
    {
      "id": 4,
      "name": "Purok 4 - Mapayapa",
      "totalMeters": 41,
      "completedMeters": 0,
      "completionPercentage": 0,
      "status": "not_started",
      "lastReadingDate": "Nov 25, 2025",
      "estimatedTime": 30,
    },
    {
      "id": 5,
      "name": "Purok 5 - Maginhawa",
      "totalMeters": 47,
      "completedMeters": 35,
      "completionPercentage": 74,
      "status": "in_progress",
      "lastReadingDate": "Dec 04, 2025",
      "estimatedTime": 20,
    },
    {
      "id": 6,
      "name": "Purok 6 - Malinis",
      "totalMeters": 33,
      "completedMeters": 33,
      "completionPercentage": 100,
      "status": "completed",
      "lastReadingDate": "Dec 04, 2025",
      "estimatedTime": 25,
    },
    {
      "id": 7,
      "name": "Purok 7 - Matahimik",
      "totalMeters": 39,
      "completedMeters": 12,
      "completionPercentage": 31,
      "status": "in_progress",
      "lastReadingDate": "Dec 02, 2025",
      "estimatedTime": 35,
    },
    {
      "id": 8,
      "name": "Purok 8 - Masigla",
      "totalMeters": 44,
      "completedMeters": 0,
      "completionPercentage": 0,
      "status": "not_started",
      "lastReadingDate": "Nov 30, 2025",
      "estimatedTime": 40,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          DashboardHeaderWidget(
            userName: "Juan Dela Cruz",
            currentDate: "Thursday, December 05, 2025",
            isSynced: _isSynced,
            onSyncTap: _handleSync,
          ),
          Container(
            color: colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              labelColor: colorScheme.primary,
              unselectedLabelColor:
                  colorScheme.onSurface.withValues(alpha: 0.6),
              tabs: const [
                Tab(text: 'Dashboard'),
                Tab(text: 'History'),
                Tab(text: 'Profile'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildHistoryTab(),
                _buildProfileTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _showRouteOptimizationModal,
              icon: CustomIconWidget(
                iconName: 'route',
                color: colorScheme.onSecondary,
                size: 20,
              ),
              label: Text(
                'Optimize Route',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSecondary,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDashboardTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final int totalTarget = _purokData.fold<int>(
        0, (sum, purok) => sum + (purok['totalMeters'] as int));
    final int totalCompleted = _purokData.fold<int>(
        0, (sum, purok) => sum + (purok['completedMeters'] as int));

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            ProgressBannerWidget(
              targetReadings: totalTarget,
              completedReadings: totalCompleted,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Purok',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (_isRefreshing)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4.w,
                  mainAxisSpacing: 2.h,
                  childAspectRatio: 0.85,
                ),
                itemCount: _purokData.length,
                itemBuilder: (context, index) {
                  final purok = _purokData[index];
                  return PurokCardWidget(
                    purokData: purok,
                    onTap: () => _navigateToPurok(purok),
                    onLongPress: () => _showQuickActionsModal(purok),
                  );
                },
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'history',
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Reading History',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'View your meter reading history here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/reading-history'),
            child: Text('View Full History'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'account_circle',
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'User Profile',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Manage your profile settings',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/user-profile-settings'),
            child: Text('Open Profile'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _isSynced = true;
    });
  }

  void _handleSync() async {
    setState(() {
      _isSynced = false;
    });

    // Simulate sync operation
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSynced = true;
    });
  }

  void _navigateToPurok(Map<String, dynamic> purok) {
    Navigator.pushNamed(
      context,
      '/meter-reading-list',
      arguments: purok,
    );
  }

  void _showQuickActionsModal(Map<String, dynamic> purok) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsModalWidget(
        purokName: purok['name'] as String,
        onViewSummary: () => _handleViewSummary(purok),
        onMarkPriority: () => _handleMarkPriority(purok),
        onOfflineSync: () => _handleOfflineSync(purok),
      ),
    );
  }

  void _showRouteOptimizationModal() {
    // Create optimized route based on efficiency
    final List<Map<String, dynamic>> optimizedRoute = List.from(_purokData)
      ..sort((a, b) {
        // Sort by status priority and estimated time
        final statusPriority = {
          'overdue': 0,
          'in_progress': 1,
          'not_started': 2,
          'completed': 3
        };
        final aPriority = statusPriority[a['status']] ?? 3;
        final bPriority = statusPriority[b['status']] ?? 3;

        if (aPriority != bPriority) return aPriority.compareTo(bPriority);
        return (a['estimatedTime'] as int).compareTo(b['estimatedTime'] as int);
      });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RouteOptimizationModalWidget(
        optimizedRoute: optimizedRoute,
        onStartRoute: _handleStartRoute,
      ),
    );
  }

  void _handleViewSummary(Map<String, dynamic> purok) {
    // Navigate to detailed summary
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing summary for ${purok['name']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleMarkPriority(Map<String, dynamic> purok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${purok['name']} marked as priority'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleOfflineSync(Map<String, dynamic> purok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Syncing ${purok['name']} for offline access'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleStartRoute() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting optimized route navigation'),
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate to first purok in optimized route
    if (_purokData.isNotEmpty) {
      Navigator.pushNamed(context, '/meter-reading-list');
    }
  }
}
