import 'package:flutter/material.dart';
import 'package:singularity/pages/beranda_page.dart';
import 'package:singularity/pages/login_regis/login_page.dart';
import 'package:singularity/pages/login_regis/register_page.dart';
import 'package:singularity/pages/mahasiswa/profile_mahasiswa.dart';
import 'package:singularity/pages/mitra/dashboard_mitra.dart';
import 'package:singularity/pages/mitra/profile_mitra.dart';
import 'package:singularity/pages/mitra/tambah_program.dart';
import 'package:singularity/pages/program_magang.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF19A7CE)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/beranda': (context) => BerandaPage(),
        '/program-magang': (context) => ProgramMagang(),
        '/mahasiswa/profile': (context) => ProfileMahasiswa(),
        '/mitra/profile': (context) => ProfileMitra(),
        '/mitra/dashboard': (context) => DashboardMitra(),
        '/mitra/tambah-program': (context) => TambahProgram(),
      },
    );
  }
}
