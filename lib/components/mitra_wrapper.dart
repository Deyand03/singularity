import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:singularity/pages/mitra/dashboard_mitra.dart';
import 'package:singularity/pages/mitra/profile_mitra.dart';
import 'package:singularity/pages/mitra/tambah_program.dart';

class MainScaffoldMitra extends StatefulWidget {
  const MainScaffoldMitra({super.key});

  @override
  State<MainScaffoldMitra> createState() => _MainScaffoldMitraState();
}

class _MainScaffoldMitraState extends State<MainScaffoldMitra> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardMitra(),    // Halaman 0
    const TambahProgram(),     // Halaman 1
    const ProfileMitra(),      // Halaman 2
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: _pages[_currentIndex],
        
        // Navbar Simpel Khusus Mitra (Bisa diganti CustomNav nanti)
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF19A7CE).withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: Color(0xFF19A7CE)),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle, color: Color(0xFF19A7CE)),
              label: 'Buat Loker',
            ),
            NavigationDestination(
              icon: Icon(Icons.business_outlined),
              selectedIcon: Icon(Icons.business, color: Color(0xFF19A7CE)),
              label: 'Profil PT',
            ),
          ],
        ),
      ),
    );
  }
}