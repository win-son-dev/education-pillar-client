import 'package:centralized_library/centralized_library.dart';
import 'package:education/di/current_user_service.dart';
import 'package:education/di/service_locator.dart';
import 'package:education/layout/responsive_layout.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _MobileShell(child: child),
      tabletBody: _TabletDesktopShell(useRail: true, child: child),
      desktopBody: _TabletDesktopShell(useRail: false, child: child),
    );
  }
}

class _MobileShell extends StatelessWidget {
  final Widget child;

  const _MobileShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final currentUser = sl<CurrentUserService>();
    final currentIndex = _getCurrentIndex(context, currentUser);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onDestinationSelected(context, index, currentUser),
        destinations: _buildDestinations(currentUser),
      ),
    );
  }
}

class _TabletDesktopShell extends StatelessWidget {
  final Widget child;
  final bool useRail;

  const _TabletDesktopShell({required this.child, required this.useRail});

  @override
  Widget build(BuildContext context) {
    final currentUser = sl<CurrentUserService>();
    final currentIndex = _getCurrentIndex(context, currentUser);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => _onDestinationSelected(context, index, currentUser),
            extended: !useRail,
            labelType: useRail ? NavigationRailLabelType.all : NavigationRailLabelType.none,
            destinations: _buildDestinations(currentUser).map((d) => NavigationRailDestination(
              icon: d.icon,
              selectedIcon: d.selectedIcon,
              label: Text(d.label),
            )).toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

int _getCurrentIndex(BuildContext context, CurrentUserService currentUser) {
  final location = GoRouterState.of(context).uri.path;

  if (currentUser.isStudent) {
    // Student tabs: Home | Schedule | Messages
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/schedule')) return 1;
    if (location.startsWith('/messages')) return 2;
    return 0;
  } else {
    // Tutor tabs: Home | Schedule | Messages | Notifications
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/schedule')) return 1;
    if (location.startsWith('/messages')) return 2;
    if (location.startsWith('/notifications')) return 3;
    return 0;
  }
}

void _onDestinationSelected(BuildContext context, int index, CurrentUserService currentUser) {
  if (currentUser.isStudent) {
    switch (index) {
      case 0: context.go('/home/student');
      case 1: context.go('/schedule');
      case 2: context.go('/messages');
    }
  } else {
    switch (index) {
      case 0: context.go('/home/tutor');
      case 1: context.go('/schedule');
      case 2: context.go('/messages');
      case 3: context.go('/notifications');
    }
  }
}

List<NavigationDestination> _buildDestinations(CurrentUserService currentUser) {
  if (currentUser.isStudent) {
    return const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Schedule'),
      NavigationDestination(icon: Icon(Icons.message_outlined), selectedIcon: Icon(Icons.message), label: 'Messages'),
    ];
  } else {
    return const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Schedule'),
      NavigationDestination(icon: Icon(Icons.message_outlined), selectedIcon: Icon(Icons.message), label: 'Messages'),
      NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Notifications'),
    ];
  }
}
