import 'package:flutter/material.dart';
import 'package:funngroapp/earnings/earnings_screen.dart';
import 'package:funngroapp/earnings/model/earnings_viewmodel.dart';
import 'package:funngroapp/projects/model/project_model.dart';
import 'package:funngroapp/projects/projects_screen.dart';

class AssessmentHome extends StatefulWidget {
  const AssessmentHome({super.key});

  @override
  State<AssessmentHome> createState() => _AssessmentHomeState();
}

class _AssessmentHomeState extends State<AssessmentHome> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    ProjectsScreen(api: ProjectsApi()),
    EarningsScreen(userId: 'user_123', api: EarningsApi()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            label: 'Part 2: Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Part 1: Earnings',
          ),
        ],
      ),
    );
  }
}
