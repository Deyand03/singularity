import 'package:flutter/material.dart';

class CustomNavMhs extends StatelessWidget {
  final int curentindex;
  const CustomNavMhs({super.key, required this.curentindex});

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
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}
