import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:singularity/providers/mahasiswa_beranda_provider.dart';
import 'package:singularity/providers/mahasiswa_provider.dart';
import 'package:singularity/utility/supabase.client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class SettingsMahasiswa extends ConsumerStatefulWidget {
  const SettingsMahasiswa({super.key});

  @override
  ConsumerState<SettingsMahasiswa> createState() => _SettingsMahasiswaState();
}

class _SettingsMahasiswaState extends ConsumerState<SettingsMahasiswa> {
  final _phoneController = TextEditingController();
  final _alamatJalanController = TextEditingController();
  final _desaController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _kabupatenController = TextEditingController();
  final _provinsiController = TextEditingController();

  bool _isLoading = true;
  bool _isUploading = false;
  String? _fotoProfilUrl;
  File? _selectedImage;

  final Color primaryColor = const Color(0xFF19A7CE);
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _alamatJalanController.dispose();
    _desaController.dispose();
    _kecamatanController.dispose();
    _kabupatenController.dispose();
    _provinsiController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final data = await supabase
            .from('mahasiswa')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        if (data != null && mounted) {
          setState(() {
            _phoneController.text = data['no_hp'] ?? '';
            _alamatJalanController.text = data['alamat'] ?? '';
            _desaController.text = data['desa'] ?? '';
            _kecamatanController.text = data['kecamatan'] ?? '';
            _kabupatenController.text = data['kabupaten'] ?? '';
            _provinsiController.text = data['provinsi'] ?? '';
            _fotoProfilUrl = data['foto_profil'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint("Error load data: $e");
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 500,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
      });

      if (mounted) {
        _showImagePreviewDialog(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memilih gambar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Pratinjau Foto",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedImage != null)
              CircleAvatar(
                radius: 60,
                backgroundImage: FileImage(_selectedImage!),
              ),
            const SizedBox(height: 20),
            Text(
              "Apakah Anda ingin menggunakan foto ini?",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage();
            },
            child: const Text("Ganti Foto"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadFoto();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text("Upload Foto"),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadFoto() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final imageFile = _selectedImage!;
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${user.id}/avatar.$fileExt';

      await supabase.storage
          .from('avatars')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
      final uniqueUrl = "$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}";

      await supabase
          .from('mahasiswa')
          .update({'foto_profil': uniqueUrl})
          .eq('user_id', user.id);

      // --- REFRESH SEMUA PROVIDER ---
      ref.invalidate(userProfileDetailProvider); // Refresh Halaman Profil
      // Pastikan nama provider ini sesuai dengan yang ada di beranda_provider.dart / common.provider.dart
      ref.invalidate(userProfileProvider); // Refresh Halaman Beranda (Banner)
      // ------------------------------

      if (mounted) {
        setState(() {
          _fotoProfilUrl = uniqueUrl;
          _selectedImage = null;
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Foto profil berhasil diganti!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _selectedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal upload: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _simpanPerubahan() async {
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase
            .from('mahasiswa')
            .update({
              'no_hp': _phoneController.text,
              'alamat': _alamatJalanController.text,
              'desa': _desaController.text,
              'kecamatan': _kecamatanController.text,
              'kabupaten': _kabupatenController.text,
              'provinsi': _provinsiController.text,
            })
            .eq('user_id', user.id);

        ref.invalidate(userProfileDetailProvider);
        // Refresh beranda juga kalau misal nama ikut berubah (opsional)
        // ref.invalidate(userProfileProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Data berhasil diperbarui!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final passController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.lock_reset_rounded, color: primaryColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  "Ubah Password",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: passController,
              obscureText: true,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: InputDecoration(
                labelText: "Password Baru",
                labelStyle: GoogleFonts.plusJakartaSans(
                  color: Colors.grey.shade600,
                ),
                prefixIcon: Icon(Icons.key_rounded, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Batal",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        if (passController.text.length < 6) {
                          throw "Password minimal 6 karakter";
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Sedang mengubah password..."),
                          ),
                        );

                        await supabase.auth.updateUser(
                          UserAttributes(password: passController.text),
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password berhasil diganti!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Gagal: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Simpan",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Profil",
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading && _fotoProfilUrl == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: Colors.grey.shade200,
                            image: DecorationImage(
                              image: _selectedImage != null
                                  ? FileImage(_selectedImage!) as ImageProvider
                                  : NetworkImage(
                                      _fotoProfilUrl ??
                                          'https://ui-avatars.com/api/?name=User',
                                    ),
                              fit: BoxFit.cover,
                              onError: (_, __) {},
                            ),
                          ),
                          child: _isUploading
                              ? Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _isUploading ? null : _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _sectionTitle("Kontak"),
                  const SizedBox(height: 12),
                  _buildTextField(
                    "Nomor Handphone",
                    _phoneController,
                    Icons.phone_outlined,
                    isNumber: true,
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle("Alamat Domisili"),
                  const SizedBox(height: 12),
                  _buildTextField(
                    "Provinsi",
                    _provinsiController,
                    Icons.map_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    "Kabupaten / Kota",
                    _kabupatenController,
                    Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    "Kecamatan",
                    _kecamatanController,
                    Icons.holiday_village_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    "Desa / Kelurahan",
                    _desaController,
                    Icons.home_work_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    "Alamat Jalan / No. Rumah",
                    _alamatJalanController,
                    Icons.signpost_outlined,
                  ),
                  const SizedBox(height: 30),
                  _sectionTitle("Keamanan Akun"),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    "Ubah Password",
                    Icons.lock_reset_rounded,
                    Colors.orange,
                    () => _showChangePasswordDialog(context),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _simpanPerubahan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Simpan Perubahan",
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: () async {
                        await supabase.auth.signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.red.shade100),
                        ),
                      ),
                      child: Text(
                        "Keluar Akun",
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.plusJakartaSans(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
          prefixIcon: Icon(
            icon,
            color: primaryColor.withOpacity(0.7),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
