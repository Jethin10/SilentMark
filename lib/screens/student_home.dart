import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'student_checkin.dart';
import 'leaderboard_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const StudentCheckIn(),
    const LeaderboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.98,
                end: 1.0,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: NavigationBar(
            height: 70,
            elevation: 0,
            backgroundColor: AppTheme.surface.withOpacity(0.9),
            indicatorColor: AppTheme.primary.withOpacity(0.1),
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              if (index == 2) {
                _confirmLogout();
              } else {
                setState(() => _currentIndex = index);
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.qr_code_scanner_rounded),
                selectedIcon: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppTheme.primary,
                ),
                label: 'Check In',
              ),
              NavigationDestination(
                icon: Icon(Icons.leaderboard_rounded),
                selectedIcon: Icon(
                  Icons.leaderboard_rounded,
                  color: AppTheme.primary,
                ),
                label: 'Leaderboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.logout_rounded, color: AppTheme.error),
                label: 'Logout',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              AuthService().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text(
              "Log Out",
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
