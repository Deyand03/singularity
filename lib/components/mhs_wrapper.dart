import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Import Riverpod
import 'package:singularity/pages/beranda_page.dart';
import 'package:singularity/pages/mahasiswa/profile_mahasiswa.dart';
import "package:singularity/components/custom_nav_mhs.dart";
import 'package:singularity/pages/program_magang.dart';
import '../providers/nav_provider.dart';

// Ubah jadi ConsumerStatefulWidget
class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  final List<Widget> _pages = [
    const BerandaPage(), // Index 0
    const ProgramMagang(), // Index 1
    const ProfileMahasiswa(), // Index 2
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navIndexProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        extendBody: true,

        body: _pages[currentIndex],

        bottomNavigationBar: CustomNavMhs(
          currentIndex: currentIndex,
          onTap: (indexBaru) {
            // 4. Update Remote pas tombol navbar dipencet
            ref.read(navIndexProvider.notifier).state = indexBaru;
          },
        ),
      ),
    );
  }
}
