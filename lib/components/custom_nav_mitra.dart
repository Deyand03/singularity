import 'package:flutter/material.dart';

class CustomNavMitra extends StatelessWidget {
  final int curentindex;
  const CustomNavMitra({super.key, required this.curentindex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(

      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: "Beranda",
        ),
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search),
          label: "Program",
        ),
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
      ],
    );
  }
}
