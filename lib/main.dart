import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:singularity/components/mhs_wrapper.dart';
import 'package:singularity/components/mitra_wrapper.dart';
import 'package:singularity/pages/login_regis/login_page.dart';
import 'package:singularity/pages/login_regis/register_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:singularity/pages/program_magang.dart';
import 'package:singularity/utility/supabase.client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zeqvmguktywqoroodkbn.supabase.co',
    anonKey: 'sb_publishable_xBnzrY0eoJCACNSp2_4-tA_XqkFfWz2',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InternGate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF19A7CE)),
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const InternetStatusOverlay(),
          ],
        );
      },
      
      // PINTU MASUK UTAMA
      home: const AuthGate(), 

      // Route Navigasi (Opsional karena kita pake AuthGate)
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/beranda': (context) => const MainScaffold(), // Home Mahasiswa
        '/mitra/home': (context) => const MainScaffoldMitra(), // Home Mitra
        '/program-magang': (context) => const ProgramMagang(),
      },
    );
  }
}

// --- LOGIC PENENTUAN ROLE (SATPAM PINTAR) ---
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkUser();
    
    // Dengerin kalau user logout/login
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _checkUser(); // Cek ulang kalau baru login
      } else if (event == AuthChangeEvent.signedOut) {
        if (mounted) {
          setState(() {
            _userRole = null;
            _isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _checkUser() async {
    try {
      final session = supabase.auth.currentSession;
      if (session == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final user = session.user;
      
      // 1. Cek Tabel 'users' untuk ambil role
      final userData = await supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          // Kalau user baru banget daftar & belum ada di tabel users, default mahasiswa dulu
          _userRole = userData != null ? userData['role'] : 'mahasiswa';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Check User: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF19A7CE))),
      );
    }

    final session = supabase.auth.currentSession;

    // 1. Kalau Gak Login -> Ke Login Page
    if (session == null) {
      return const LoginPage();
    }

    // 2. Kalau Login -> Cek Role
    if (_userRole == 'mitra') {
      return const MainScaffoldMitra(); // Masuk Rumah Mitra
    } else {
      return const MainScaffold(); // Masuk Rumah Mahasiswa (Default)
    }
  }
}

// ... Widget InternetStatusOverlay sama kayak sebelumnya ...
class InternetStatusOverlay extends StatefulWidget {
  const InternetStatusOverlay({super.key});
  @override
  State<InternetStatusOverlay> createState() => _InternetStatusOverlayState();
}

class _InternetStatusOverlayState extends State<InternetStatusOverlay> {
  bool _isOffline = false;
  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final isOffline = results.contains(ConnectivityResult.none);
      if (mounted) setState(() => _isOffline = isOffline);
    });
  }
  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: const BoxDecoration(color: Colors.redAccent),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("Tidak ada koneksi internet.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}