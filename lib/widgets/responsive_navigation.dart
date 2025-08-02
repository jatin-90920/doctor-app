import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ayurvedic_doctor_crm/utils/responsive_utils.dart';
import 'package:ayurvedic_doctor_crm/screens/responsive_home_screen.dart';
import 'package:ayurvedic_doctor_crm/screens/patients/patient_list_screen.dart';
import 'package:ayurvedic_doctor_crm/screens/patients/add_edit_patient_screen.dart';
import 'package:ayurvedic_doctor_crm/screens/settings/settings_screen.dart';

/// Navigation item model
class NavigationItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String route;
  final Widget Function(BuildContext context) builder;

  const NavigationItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    required this.route,
    required this.builder,
  });
}

/// Responsive navigation widget
class ResponsiveNavigation extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onIndexChanged;

  const ResponsiveNavigation({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  State<ResponsiveNavigation> createState() => _ResponsiveNavigationState();
}

class _ResponsiveNavigationState extends State<ResponsiveNavigation> {
  void _navigateToPatients() {
    widget.onIndexChanged(1); // Navigate to patients tab (index 1)
  }

  @override
  Widget build(BuildContext context) {
    final navigationItems = [
      NavigationItem(
        label: 'Dashboard',
        icon: MdiIcons.viewDashboard,
        activeIcon: MdiIcons.viewDashboard,
        route: '/dashboard',
        builder: (context) => const ResponsiveHomeScreen(),
      ),
      NavigationItem(
        label: 'Patients',
        icon: MdiIcons.accountGroup,
        activeIcon: MdiIcons.accountGroup,
        route: '/patients',
        builder: (context) => const PatientListScreen(),
      ),
      NavigationItem(
        label: 'Add Patient',
        icon: MdiIcons.accountPlus,
        activeIcon: MdiIcons.accountPlus,
        route: '/add-patient',
        builder: (context) => AddEditPatientScreen(
          onPatientSaved: () => _navigateToPatients(), // ✅ This works now
        ),
      ),
      NavigationItem(
        label: 'Settings',
        icon: MdiIcons.cog,
        activeIcon: MdiIcons.cog,
        route: '/settings',
        builder: (context) => const SettingsScreen(),
      ),
    ];

    return ResponsiveLayout(
      mobile: _buildMobileLayout(navigationItems),
      tablet: _buildTabletLayout(navigationItems),
      desktop: _buildDesktopLayout(navigationItems),
    );
  }

  /// Mobile layout with bottom navigation
  Widget _buildMobileLayout(List<NavigationItem> navigationItems) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: widget.currentIndex,
        onTap: widget.onIndexChanged,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        items: navigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(item.activeIcon ?? item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  /// Tablet layout with rail navigation
  Widget _buildTabletLayout(List<NavigationItem> navigationItems) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: widget.currentIndex,
            onDestinationSelected: widget.onIndexChanged,
            labelType: NavigationRailLabelType.selected,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.primary,
            ),
            unselectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            destinations: navigationItems.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.activeIcon ?? item.icon),
                label: Text(item.label),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  /// Desktop layout with sidebar navigation
  Widget _buildDesktopLayout(List<NavigationItem> navigationItems) {
    return Scaffold(
      body: Row(
        children: [
          _buildDesktopSidebar(navigationItems),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  /// Desktop sidebar widget
  Widget _buildDesktopSidebar(List<NavigationItem> navigationItems) {
    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // App header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    MdiIcons.leaf,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ayurvedic CRM',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Doctor Portal',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: navigationItems.length,
              itemBuilder: (context, index) {
                final item = navigationItems[index];
                final isSelected = index == widget.currentIndex;

                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    selected: isSelected,
                    selectedTileColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(
                      isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    onTap: () => widget.onIndexChanged(index),
                  ),
                );
              },
            ),
          ),

          const Divider(),

          // User profile section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  child: Icon(
                    MdiIcons.account,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. Ayurveda',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        'Practitioner',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(MdiIcons.dotsVertical),
                  onPressed: () {
                    // Show user menu
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Main navigation wrapper
class ResponsiveNavigationWrapper extends StatefulWidget {
  const ResponsiveNavigationWrapper({super.key});

  @override
  State<ResponsiveNavigationWrapper> createState() =>
      _ResponsiveNavigationWrapperState();
}

class _ResponsiveNavigationWrapperState
    extends State<ResponsiveNavigationWrapper> {
  int _currentIndex = 0;

  void _navigateToPatients() {
    setState(() {
      _currentIndex = 1; // Navigate to patients tab
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create navigation items inside build method
    final navigationItems = [
      NavigationItem(
        label: 'Dashboard',
        icon: MdiIcons.viewDashboard,
        activeIcon: MdiIcons.viewDashboard,
        route: '/dashboard',
        builder: (context) => const ResponsiveHomeScreen(),
      ),
      NavigationItem(
        label: 'Patients',
        icon: MdiIcons.accountGroup,
        activeIcon: MdiIcons.accountGroup,
        route: '/patients',
        builder: (context) => const PatientListScreen(),
      ),
      NavigationItem(
        label: 'Add Patient',
        icon: MdiIcons.accountPlus,
        activeIcon: MdiIcons.accountPlus,
        route: '/add-patient',
        builder: (context) => AddEditPatientScreen(
          onPatientSaved: () => _navigateToPatients(), // ✅ This works now
        ),
      ),
      NavigationItem(
        label: 'Settings',
        icon: MdiIcons.cog,
        activeIcon: MdiIcons.cog,
        route: '/settings',
        builder: (context) => const SettingsScreen(),
      ),
    ];

    return ResponsiveNavigation(
      currentIndex: _currentIndex,
      onIndexChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      child: navigationItems[_currentIndex].builder(context),
    );
  }
}
