import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomAppBarVariant {
  standard,
  withSearch,
  withActions,
  minimal,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final VoidCallback? onSearchPressed;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.standard,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.onSearchPressed,
    this.searchController,
    this.onSearchChanged,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomAppBarVariant.withSearch:
        return _buildSearchAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.withActions:
        return _buildActionsAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.minimal:
        return _buildMinimalAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.standard:
      default:
        return _buildStandardAppBar(context, theme, colorScheme);
    }
  }

  Widget _buildStandardAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? colorScheme.onPrimary,
        ),
      ),
      backgroundColor: backgroundColor ?? colorScheme.primary,
      foregroundColor: foregroundColor ?? colorScheme.onPrimary,
      elevation: elevation ?? 2.0,
      centerTitle: centerTitle,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: _buildDefaultActions(context),
    );
  }

  Widget _buildSearchAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          style: GoogleFonts.inter(
            color: foregroundColor ?? colorScheme.onPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: GoogleFonts.inter(
              color: (foregroundColor ?? colorScheme.onPrimary)
                  .withValues(alpha: 0.7),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: (foregroundColor ?? colorScheme.onPrimary)
                  .withValues(alpha: 0.7),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
      backgroundColor: backgroundColor ?? colorScheme.primary,
      foregroundColor: foregroundColor ?? colorScheme.onPrimary,
      elevation: elevation ?? 2.0,
      centerTitle: centerTitle,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: _buildDefaultActions(context),
    );
  }

  Widget _buildActionsAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? colorScheme.onPrimary,
        ),
      ),
      backgroundColor: backgroundColor ?? colorScheme.primary,
      foregroundColor: foregroundColor ?? colorScheme.onPrimary,
      elevation: elevation ?? 2.0,
      centerTitle: centerTitle,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchPressed ??
              () {
                Navigator.pushNamed(context, '/meter-reading-list');
              },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Show notifications
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'profile':
                Navigator.pushNamed(context, '/user-profile-settings');
                break;
              case 'history':
                Navigator.pushNamed(context, '/reading-history');
                break;
              case 'logout':
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login-screen',
                  (route) => false,
                );
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline),
                  SizedBox(width: 8),
                  Text('Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history),
                  SizedBox(width: 8),
                  Text('History'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
        ),
        ...(actions ?? []),
      ],
    );
  }

  Widget _buildMinimalAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: foregroundColor ?? colorScheme.onSurface,
        ),
      ),
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation ?? 0.0,
      centerTitle: centerTitle,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
    );
  }

  List<Widget> _buildDefaultActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.account_circle_outlined),
        onPressed: () {
          Navigator.pushNamed(context, '/user-profile-settings');
        },
      ),
    ];
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
