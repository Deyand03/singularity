import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:singularity/pages/mitra/dashboard_mitra.dart';
import 'package:singularity/pages/mitra/profile_mitra.dart';
import 'package:singularity/pages/mitra/tambah_program.dart';
import '../../components/custom_nav_mitra.dart'; // Import Component Baru

class MainScaffoldMitra extends StatefulWidget {
  const MainScaffoldMitra({super.key});

  @override
  State<MainScaffoldMitra> createState() => _MainScaffoldMitraState();
}

class _MainScaffoldMitraState extends State<MainScaffoldMitra> {
  int _currentIndex = 0;

  // DAFTAR HALAMAN MITRA (5 MENU)
  final List<Widget> _pages = [
    const DashboardMitra(), // 0. Beranda/Dashboard
    const PlaceholderListLoker(), // 1. Kelola Loker (Placeholder)
    const TambahProgram(), // 2. TAMBAH (Tengah)
    const PlaceholderListPelamar(), // 3. Pelamar (Placeholder)
    const ProfileMitra(), // 4. Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        // Body sesuai index yang dipilih
        body: _pages[_currentIndex],

        // --- TOMBOL TENGAH (FAB) ---
        floatingActionButton: SizedBox(
          width: 65,
          height: 65,
          child: FloatingActionButton(
            onPressed: () => _onItemTapped(2), // Pindah ke index 2 (Tambah)
            backgroundColor: const Color(0xFF19A7CE), // Warna Tema Biru
            shape: const CircleBorder(), // Bulat sempurna
            elevation: 8, // Sedikit lebih tinggi biar pop-out
            child: Icon(
              Icons.add_rounded,
              size: 32,
              // Icon putih kalau aktif, agak transparan kalau gak aktif
              color: _currentIndex == 2
                  ? Colors.white
                  : Colors.white.withOpacity(0.9),
            ),
          ),
        ),
        // Posisi FAB 'Nancep' di tengah Navbar
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // --- NAVBAR CUSTOM (IMPORT) ---
        bottomNavigationBar: CustomNavMitra(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

// --- PLACEHOLDER PAGES ---

class PlaceholderListLoker extends StatelessWidget {
  const PlaceholderListLoker({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Halaman Kelola Lowongan (Segera Hadir)")),
    );
  }
}

class PlaceholderListPelamar extends StatelessWidget {
  const PlaceholderListPelamar({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Halaman Review Pelamar (Segera Hadir)")),
    );
  }
}
