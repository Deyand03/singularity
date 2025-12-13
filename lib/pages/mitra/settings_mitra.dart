import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:singularity/utility/supabase.client.dart';
import '../../providers/mitra_profile_provider.dart';

class SettingsMitra extends ConsumerStatefulWidget {
  const SettingsMitra({super.key});

  @override
  ConsumerState<SettingsMitra> createState() => _SettingsMitraState();
}

class _SettingsMitraState extends ConsumerState<SettingsMitra> {
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _deskripsiController = TextEditingController();

  bool _isLoading = true;
  bool _isUploading = false;
  String? _logoUrl;
  String? _bannerUrl;

  final ImagePicker _picker = ImagePicker();
  final Color primaryColor = const Color(0xFF19A7CE);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await ref.read(mitraProfileProvider.future);
    if (data != null && mounted) {
      setState(() {
        _namaController.text = data['nama_perusahaan'] ?? '';
        _alamatController.text = data['alamat_perusahaan'] ?? '';
        _deskripsiController.text = data['deskripsi'] ?? '';
        _logoUrl = data['logo_perusahaan'];
        _bannerUrl = data['banner_perusahaan'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  // LOGIC UPLOAD GAMBAR (Generic buat Logo & Banner)
  Future<void> _uploadImage(bool isLogo) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return;

      setState(() => _isUploading = true);
      final user = supabase.auth.currentUser;
      final fileExt = image.path.split('.').last;
      final type = isLogo ? 'logo' : 'banner';
      // Nama file unik pake timestamp biar gak kena cache
      final fileName =
          'mitra/${user!.id}/${type}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await supabase.storage.from('avatars').upload(fileName, File(image.path));
      final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      // Update Database
      await supabase
          .from('mitra')
          .update({isLogo ? 'logo_perusahaan' : 'banner_perusahaan': publicUrl})
          .eq('user_id', user.id);

      // Refresh Provider
      ref.invalidate(mitraProfileProvider);

      if (mounted) {
        setState(() {
          if (isLogo)
            _logoUrl = publicUrl;
          else
            _bannerUrl = publicUrl;
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gambar berhasil diupdate!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      await supabase
          .from('mitra')
          .update({
            'nama_perusahaan': _namaController.text,
            'alamat_perusahaan': _alamatController.text,
            'deskripsi': _deskripsiController.text,
          })
          .eq('user_id', user!.id);

      ref.invalidate(mitraProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil disimpan!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Profil Perusahaan",
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BANNER & LOGO EDIT
                  SizedBox(
                    height: 200,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Banner
                        GestureDetector(
                          onTap: () => _uploadImage(false),
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                              image: _bannerUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(_bannerUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _bannerUrl == null
                                ? const Center(
                                    child: Icon(
                                      Icons.add_a_photo,
                                      color: Colors.grey,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        // Logo
                        Positioned(
                          bottom: 0,
                          left: 24,
                          child: GestureDetector(
                            onTap: () => _uploadImage(true),
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                  ),
                                ],
                                image: _logoUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(_logoUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _logoUrl == null
                                  ? const Icon(
                                      Icons.business,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        // Loading Indicator
                        if (_isUploading)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black26,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildTextField(
                    "Nama Perusahaan",
                    _namaController,
                    Icons.domain,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    "Alamat Kantor",
                    _alamatController,
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextArea("Deskripsi Perusahaan", _deskripsiController),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Simpan Perubahan",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: () async {
                        await supabase.auth.signOut();
                        if (context.mounted)
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(
                        "Logout",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: primaryColor),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 5,
          style: GoogleFonts.plusJakartaSans(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
