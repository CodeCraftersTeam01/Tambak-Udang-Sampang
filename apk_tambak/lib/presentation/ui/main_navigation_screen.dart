import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'kolam_list_screen.dart';
import 'pakan_screen.dart';
import 'panen_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const KolamListScreen(),
    const PakanScreen(),
    const PanenScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.water),
            label: 'Kolam',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Pakan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Panen',
          ),
        ],
      ),
    );
  }
}
