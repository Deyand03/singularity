import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:singularity/pages/mitra/dashboard_mitra.dart';
import 'package:singularity/pages/mitra/lowongan_mitra.dart';
import 'package:singularity/pages/mitra/pelamar_mitra.dart';
import 'package:singularity/pages/mitra/profile_mitra.dart';
import 'package:singularity/pages/mitra/tambah_program.dart';
import '../../components/custom_nav_mitra.dart';
import '../../providers/nav_provider.dart'; 

// Ubah jadi ConsumerStatefulWidget
class MainScaffoldMitra extends ConsumerStatefulWidget {
  const MainScaffoldMitra({super.key});

  @override
  ConsumerState<MainScaffoldMitra> createState() => _MainScaffoldMitraState();
}

class _MainScaffoldMitraState extends ConsumerState<MainScaffoldMitra> {

  final List<Widget> _pages = [
    const DashboardMitra(),
    const LowonganMitra(),
    const TambahProgram(),
    const PelamarPage(),
    const ProfileMitra(), 
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(navIndexProvider.notifier).state = 0);
  }

  void _onItemTapped(int index) {
    ref.read(navIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navIndexProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),

        // Body berubah sesuai Provider
        body: _pages[currentIndex],

        // FAB (Tombol Tengah)
        floatingActionButton: SizedBox(
          width: 65,
          height: 65,
          child: FloatingActionButton(
            onPressed: () => _onItemTapped(2), // Pindah ke index 2 (Tambah)
            backgroundColor: const Color(0xFF19A7CE),
            shape: const CircleBorder(),
            elevation: 8,
            child: Icon(
              Icons.add_rounded,
              size: 32,
              color: currentIndex == 2
                  ? Colors.white
                  : Colors.white.withOpacity(0.9),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // Navbar Custom
        bottomNavigationBar: CustomNavMitra(
          currentIndex: currentIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}