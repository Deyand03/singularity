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
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF19A7CE)),
      ),
      home: const AuthGate(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/main': (context) => MainScaffold(),
      },
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
          return const MainScaffold();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
