import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomBottomBarVariant {
  standard,
  floating,
  notched,
}

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final CustomBottomBarVariant variant;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? elevation;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = CustomBottomBarVariant.standard,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final items = _getBottomNavigationItems();

    switch (variant) {
      case CustomBottomBarVariant.floating:
        return _buildFloatingBottomBar(context, theme, colorScheme, items);
      case CustomBottomBarVariant.notched:
        return _buildNotchedBottomBar(context, theme, colorScheme, items);
      case CustomBottomBarVariant.standard:
      default:
        return _buildStandardBottomBar(context, theme, colorScheme, items);
    }
  }

  List<BottomNavigationBarItem> _getBottomNavigationItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.list_alt_outlined),
        activeIcon: Icon(Icons.list_alt),
        label: 'Readings',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.add_circle_outline),
        activeIcon: Icon(Icons.add_circle),
        label: 'Add Entry',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long_outlined),
        activeIcon: Icon(Icons.receipt_long),
        label: 'Billing',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.history_outlined),
        activeIcon: Icon(Icons.history),
        label: 'History',
      ),
    ];
  }

  Widget _buildStandardBottomBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    List<BottomNavigationBarItem> items,
  ) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        _handleNavigation(context, index);
        onTap(index);
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      selectedItemColor: selectedItemColor ?? colorScheme.primary,
      unselectedItemColor:
          unselectedItemColor ?? colorScheme.onSurface.withValues(alpha: 0.6),
      elevation: elevation ?? 8.0,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      items: items,
    );
  }

  Widget _buildFloatingBottomBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    List<BottomNavigationBarItem> items,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            _handleNavigation(context, index);
            onTap(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: selectedItemColor ?? colorScheme.primary,
          unselectedItemColor: unselectedItemColor ??
              colorScheme.onSurface.withValues(alpha: 0.6),
          elevation: 0,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: items,
        ),
      ),
    );
  }

  Widget _buildNotchedBottomBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    List<BottomNavigationBarItem> items,
  ) {
    return BottomAppBar(
      color: backgroundColor ?? colorScheme.surface,
      elevation: elevation ?? 8.0,
      notchMargin: 8.0,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == currentIndex;

            // Skip the middle item for FAB space
            if (index == 2) {
              return const SizedBox(width: 48);
            }

            return InkWell(
              onTap: () {
                _handleNavigation(context, index);
                onTap(index);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isSelected ? item.activeIcon ?? item.icon : item.icon,
                    const SizedBox(height: 4),
                    Text(
                      item.label ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                        color: isSelected
                            ? (selectedItemColor ?? colorScheme.primary)
                            : (unselectedItemColor ??
                                colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    final routes = [
      '/purok-selection-dashboard',
      '/meter-reading-list',
      '/meter-reading-entry',
      '/billing-receipt-generation',
      '/reading-history',
    ];

    if (index < routes.length) {
      Navigator.pushNamed(context, routes[index]);
    }
  }
}
