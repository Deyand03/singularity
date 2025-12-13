import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:singularity/utility/supabase.client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterMitraPage extends StatefulWidget {
  const RegisterMitraPage({super.key});

  @override
  State<RegisterMitraPage> createState() => _RegisterMitraPageState();
}

class _RegisterMitraPageState extends State<RegisterMitraPage> {
  bool _isLoading = false;
  
  // Controllers Akun
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Controllers Perusahaan
  final _namaPerusahaanController = TextEditingController();
  final _alamatController = TextEditingController();
  final _deskripsiController = TextEditingController();

  // Image Files
  File? _logoFile;
  File? _bannerFile;
  final ImagePicker _picker = ImagePicker();

  final Color _primaryColor = const Color(0xFF19A7CE); // Warna Tema

  // --- LOGIC PICK IMAGE ---
  Future<void> _pickImage(bool isLogo) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          if (isLogo) {
            _logoFile = File(image.path);
          } else {
            _bannerFile = File(image.path);
          }
        });
      }
    } catch (e) {
      debugPrint("Error pick image: $e");
    }
  }

  // --- LOGIC REGISTER ---
  Future<void> _handleRegister() async {
    // 1. Validasi Input
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _namaPerusahaanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email, Password, dan Nama Perusahaan wajib diisi!'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password konfirmasi tidak cocok!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. DAFTAR AUTH
      final authResponse = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'role': 'mitra', // PENTING: Role Mitra
          'full_name': _namaPerusahaanController.text,
        },
      );

      final user = authResponse.user;

      if (user != null) {
        String? logoUrl;
        String? bannerUrl;

        // 3. UPLOAD GAMBAR (Jika ada)
        // Kita pakai bucket 'avatars' atau bikin bucket baru 'mitra_assets' di Supabase
        if (_logoFile != null) {
          final path = 'mitra/${user.id}/logo_${DateTime.now().millisecondsSinceEpoch}.jpg';
          await supabase.storage.from('avatars').upload(path, _logoFile!);
          logoUrl = supabase.storage.from('avatars').getPublicUrl(path);
        }

        if (_bannerFile != null) {
          final path = 'mitra/${user.id}/banner_${DateTime.now().millisecondsSinceEpoch}.jpg';
          await supabase.storage.from('avatars').upload(path, _bannerFile!);
          bannerUrl = supabase.storage.from('avatars').getPublicUrl(path);
        }

        // 4. INSERT KE TABEL 'mitra'
        await supabase.from('mitra').insert({
          'user_id': user.id,
          'nama_perusahaan': _namaPerusahaanController.text,
          'alamat_perusahaan': _alamatController.text,
          'deskripsi': _deskripsiController.text,
          'logo_perusahaan': logoUrl,
          'banner_perusahaan': bannerUrl,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrasi Mitra Berhasil! Silakan Login.'),
              backgroundColor: Colors.green,
            ),
          );
          // Balik ke Login dan hapus semua route sebelumnya
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      }

    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Registrasi Mitra",
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bergabung sebagai Mitra",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 5),
            const Text(
              "Temukan talenta terbaik untuk perusahaan Anda.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // --- SECTION 1: BRANDING (LOGO & BANNER) ---
            _buildSectionLabel("Branding Perusahaan"),
            const SizedBox(height: 10),
            
            // BANNER UPLOAD
            GestureDetector(
              onTap: () => _pickImage(false), // False = Banner
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  image: _bannerFile != null 
                    ? DecorationImage(image: FileImage(_bannerFile!), fit: BoxFit.cover)
                    : null,
                ),
                child: _bannerFile == null 
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_rounded, size: 40, color: _primaryColor),
                        const SizedBox(height: 8),
                        Text("Upload Banner Perusahaan", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    )
                  : null,
              ),
            ),
            
            const SizedBox(height: 20),

            // LOGO UPLOAD (Overlap dikit ke banner biar kece)
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                      image: _logoFile != null 
                        ? DecorationImage(image: FileImage(_logoFile!), fit: BoxFit.cover)
                        : null,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                      ]
                    ),
                    child: _logoFile == null 
                      ? Icon(Icons.business_rounded, size: 40, color: Colors.grey.shade400)
                      : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: GestureDetector(
                      onTap: () => _pickImage(true), // True = Logo
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- SECTION 2: PROFIL PERUSAHAAN ---
            _buildSectionLabel("Profil Perusahaan"),
            _buildInputField(controller: _namaPerusahaanController, hintText: 'Nama Perusahaan', icon: Icons.domain),
            const SizedBox(height: 15),
            _buildInputField(controller: _alamatController, hintText: 'Alamat Lengkap', icon: Icons.location_on_outlined),
            const SizedBox(height: 15),
            // Deskripsi (TextArea)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _deskripsiController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Deskripsi singkat perusahaan...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- SECTION 3: AKUN LOGIN ---
            _buildSectionLabel("Akun Login"),
            _buildInputField(controller: _emailController, hintText: 'Email Bisnis', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 15),
            _buildInputField(controller: _passwordController, hintText: 'Password', icon: Icons.lock_outline, obscureText: true),
            const SizedBox(height: 15),
            _buildInputField(controller: _confirmPasswordController, hintText: 'Konfirmasi Password', icon: Icons.lock_outline, obscureText: true),

            const SizedBox(height: 40),

            // TOMBOL DAFTAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                  shadowColor: _primaryColor.withOpacity(0.4),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Daftar Sebagai Mitra',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: GoogleFonts.plusJakartaSans(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}