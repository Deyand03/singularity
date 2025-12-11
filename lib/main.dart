import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:singularity/components/main_wrapper.dart';
import 'package:singularity/pages/login_regis/login_page.dart';
import 'package:singularity/pages/login_regis/register_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      title: "Interngate",
      theme: ThemeData(
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF19A7CE)),
      ),
      builder: (context, child) =>
          Stack(children: [child!, const InternetStatusOverlay()]),
      home: const AuthGate(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/main': (context) => MainScaffold(),
      },
    );
  }
}

class InternetStatusOverlay extends StatefulWidget {
  const InternetStatusOverlay({super.key});

  @override
  State<InternetStatusOverlay> createState() => _InternetStatusOverlayState();
}

class _InternetStatusOverlayState extends State<InternetStatusOverlay> {
  bool _isOffline = false; // Default anggap online

  @override
  void initState() {
    super.initState();
    // Mulai dengerin perubahan sinyal
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      // Kalau results mengandung 'none', berarti gak ada koneksi
      final isOffline = results.contains(ConnectivityResult.none);

      if (mounted) {
        setState(() {
          _isOffline = isOffline;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kalau Online, jangan tampilin apa-apa (SizedBox kosong)
    if (!_isOffline) return const SizedBox.shrink();

    // Kalau Offline, tampilin Banner Merah di bawah
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Material(
        // Butuh Material biar gak error garis kuning
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: const BoxDecoration(color: Colors.redAccent),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                "Tidak ada koneksi internet!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;
        if (session != null) {
          return MainScaffold();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
