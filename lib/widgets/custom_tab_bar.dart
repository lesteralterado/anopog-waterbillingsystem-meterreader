import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomTabBarVariant {
  standard,
  scrollable,
  segmented,
  pills,
}

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;
  final CustomTabBarVariant variant;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.variant = CustomTabBarVariant.standard,
    this.backgroundColor,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.isScrollable = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomTabBarVariant.scrollable:
        return _buildScrollableTabBar(context, theme, colorScheme);
      case CustomTabBarVariant.segmented:
        return _buildSegmentedTabBar(context, theme, colorScheme);
      case CustomTabBarVariant.pills:
        return _buildPillsTabBar(context, theme, colorScheme);
      case CustomTabBarVariant.standard:
      default:
        return _buildStandardTabBar(context, theme, colorScheme);
    }
  }

  Widget _buildStandardTabBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      color: backgroundColor ?? colorScheme.surface,
      padding: padding,
      child: TabBar(
        controller: controller,
        onTap: onTap,
        isScrollable: isScrollable,
        indicatorColor: indicatorColor ?? colorScheme.primary,
        labelColor: labelColor ?? colorScheme.primary,
        unselectedLabelColor: unselectedLabelColor ??
            colorScheme.onSurface.withValues(alpha: 0.6),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildScrollableTabBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      color: backgroundColor ?? colorScheme.surface,
      padding: padding,
      child: TabBar(
        controller: controller,
        onTap: onTap,
        isScrollable: true,
        indicatorColor: indicatorColor ?? colorScheme.primary,
        labelColor: labelColor ?? colorScheme.primary,
        unselectedLabelColor: unselectedLabelColor ??
            colorScheme.onSurface.withValues(alpha: 0.6),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildSegmentedTabBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      color: backgroundColor ?? colorScheme.surface,
      padding: padding ?? const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TabBar(
          controller: controller,
          onTap: onTap,
          isScrollable: isScrollable,
          indicator: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(4),
          labelColor: labelColor ?? colorScheme.onPrimary,
          unselectedLabelColor: unselectedLabelColor ??
              colorScheme.onSurface.withValues(alpha: 0.8),
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          dividerColor: Colors.transparent,
          tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
    );
  }

  Widget _buildPillsTabBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      color: backgroundColor ?? colorScheme.surface,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = controller?.index == index;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  controller?.animateTo(index);
                  onTap?.call(index);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (indicatorColor ?? colorScheme.primary)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? (indicatorColor ?? colorScheme.primary)
                          : colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    tab,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                      color: isSelected
                          ? (labelColor ?? colorScheme.onPrimary)
                          : (unselectedLabelColor ??
                              colorScheme.onSurface.withValues(alpha: 0.8)),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

class CustomTabBarView extends StatelessWidget {
  final List<Widget> children;
  final TabController? controller;
  final DragStartBehavior dragStartBehavior;
  final double? viewportFraction;

  const CustomTabBarView({
    super.key,
    required this.children,
    this.controller,
    this.dragStartBehavior = DragStartBehavior.start,
    this.viewportFraction,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      dragStartBehavior: dragStartBehavior,
      viewportFraction: viewportFraction,
      children: children,
    );
  }
}