import 'package:flutter/material.dart';
import 'package:singularity/pages/beranda_page.dart';
import 'package:singularity/pages/mahasiswa/profile_mahasiswa.dart';
import "package:singularity/components/custom_nav_mhs.dart";
import 'package:singularity/pages/program_magang.dart';

// HANYA INI YANG PERLU STATEFUL
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const BerandaPage(), // Index 0
    const ProgramMagang(), // Index 1
    const ProfileMahasiswa(), // Index 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],

      bottomNavigationBar: CustomNavMhs(
        currentIndex: _currentIndex,
        onTap: (indexBaru) {
          setState(() {
            _currentIndex = indexBaru;
          });
        },
      ),
    );
  }
}
