import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:singularity/providers/mitra_lowongan_provider.dart';
import 'package:singularity/utility/supabase.client.dart';
import '../../providers/nav_provider.dart'; 

class TambahProgram extends ConsumerStatefulWidget {
  const TambahProgram({super.key});

  @override
  ConsumerState<TambahProgram> createState() => _TambahProgramState();
}

class _TambahProgramState extends ConsumerState<TambahProgram> {
  bool _isLoading = false;
  
  // Controllers
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _kualifikasiController = TextEditingController();
  final _kuotaController = TextEditingController();

  // Date State
  DateTime? _batasPendaftaran;
  DateTime? _awalMagang;
  DateTime? _selesaiMagang;

  // Category State
  String _selectedCategory = "Web Developer"; // Default
  final List<String> _categories = [
    "Web Developer",
    "Mobile Developer",
    "UI/UX Designer",
    "DevOps",
    "CyberSecurity",
  ];

  // Image State
  File? _bannerFile;
  final ImagePicker _picker = ImagePicker();
  final Color primaryColor = const Color(0xFF19A7CE);

  // --- LOGIC PICK IMAGE ---
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _bannerFile = File(image.path);
      });
    }
  }

  // --- LOGIC DATE PICKER ---
  Future<void> _selectDate(BuildContext context, String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (type == 'batas') _batasPendaftaran = picked;
        if (type == 'awal') _awalMagang = picked;
        if (type == 'selesai') _selesaiMagang = picked;
      });
    }
  }

  // --- LOGIC SUBMIT ---
  Future<void> _handleSubmit() async {
    // 1. Validasi
    if (_judulController.text.isEmpty || 
        _deskripsiController.text.isEmpty ||
        _kualifikasiController.text.isEmpty ||
        _kuotaController.text.isEmpty ||
        _batasPendaftaran == null ||
        _awalMagang == null ||
        _selesaiMagang == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua form!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // 2. Ambil Mitra ID (Bukan User ID)
      final mitraRes = await supabase
          .from('mitra')
          .select('id')
          .eq('user_id', user.id)
          .single();
      final mitraId = mitraRes['id'];

      String? bannerUrl;

      // 3. Upload Gambar (Jika ada)
      if (_bannerFile != null) {
        final fileExt = _bannerFile!.path.split('.').last;
        final fileName = 'loker/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        
        // Upload ke bucket 'avatars' (atau bucket khusus 'banners' kalau udah buat)
        await supabase.storage.from('avatars').upload(fileName, _bannerFile!);
        bannerUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
      }

      // 4. Insert ke Supabase
      await supabase.from('program_magang').insert({
        'mitra_id': mitraId,
        'judul': _judulController.text,
        'deskripsi_program': _deskripsiController.text,
        'kualifikasi': _kualifikasiController.text,
        'kuota': int.parse(_kuotaController.text),
        'kategori': _selectedCategory,
        'batas_pendaftaran': _batasPendaftaran!.toIso8601String(),
        'awal_magang': _awalMagang!.toIso8601String(),
        'selesai_magang': _selesaiMagang!.toIso8601String(),
        'gambar': bannerUrl,
        'status_magang': 'buka', // Default Buka
      });

      // 5. Sukses & Reset
      ref.invalidate(mitraJobsProvider); // Refresh list di Lokerku
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lowongan berhasil diterbitkan!"), backgroundColor: Colors.green),
        );
        
        // Pindah ke Tab "Lokerku" (Index 1) biar langsung liat hasilnya
        ref.read(navIndexProvider.notifier).state = 1;
        
        // Reset Form (Opsional, karena widget bakal ke-rebuild kalau pindah page)
        _judulController.clear();
        _deskripsiController.clear();
        setState(() {
          _bannerFile = null;
          _batasPendaftaran = null;
        });
      }

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
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
        centerTitle: true,
        title: Text(
          "Buat Lowongan Baru",
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // 1. BANNER UPLOAD (Hero Section)
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  image: _bannerFile != null 
                    ? DecorationImage(image: FileImage(_bannerFile!), fit: BoxFit.cover)
                    : null,
                ),
                child: _bannerFile == null 
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(Icons.add_photo_alternate_rounded, size: 30, color: primaryColor),
                        ),
                        const SizedBox(height: 10),
                        Text("Upload Banner Lowongan", style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                      ],
                    )
                  : Stack(
                      children: [
                        Positioned(
                          right: 10, top: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 18,
                            child: Icon(Icons.edit, size: 18, color: primaryColor),
                          ),
                        )
                      ],
                    ),
              ),
            ),
            
            const SizedBox(height: 30),

            // 2. JUDUL & KUOTA
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField("Judul Posisi", _judulController, Icons.work_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: _buildTextField("Kuota", _kuotaController, Icons.people_outline, isNumber: true),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 3. KATEGORI (Choice Chips)
            Text("Kategori", style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  labelStyle: GoogleFonts.plusJakartaSans(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  selected: isSelected,
                  selectedColor: primaryColor,
                  backgroundColor: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: isSelected ? primaryColor : Colors.grey.shade200),
                  ),
                  onSelected: (val) => setState(() => _selectedCategory = cat),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // 4. TANGGAL PENTING
            Text("Jadwal Program", style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
            const SizedBox(height: 10),
            _buildDatePickerTile("Batas Pendaftaran", _batasPendaftaran, () => _selectDate(context, 'batas')),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildDatePickerTile("Mulai", _awalMagang, () => _selectDate(context, 'awal'))),
                const SizedBox(width: 10),
                Expanded(child: _buildDatePickerTile("Selesai", _selesaiMagang, () => _selectDate(context, 'selesai'))),
              ],
            ),

            const SizedBox(height: 24),

            // 5. DETAIL (Deskripsi & Kualifikasi)
            _buildTextArea("Deskripsi Pekerjaan", _deskripsiController),
            const SizedBox(height: 16),
            _buildTextArea("Kualifikasi (Pisahkan dengan baris baru)", _kualifikasiController),

            const SizedBox(height: 40),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: primaryColor.withOpacity(0.4),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Terbitkan Lowongan",
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER ---

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.black87),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: true,
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
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            maxLines: 5,
            style: GoogleFonts.plusJakartaSans(color: Colors.black87),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerTile(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: date != null ? primaryColor : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey.shade500)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? "${date.day}/${date.month}/${date.year}" : "Pilih Tgl",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold, 
                    color: date != null ? Colors.black87 : Colors.grey.shade400
                  ),
                ),
                Icon(Icons.calendar_today_rounded, size: 16, color: date != null ? primaryColor : Colors.grey.shade300),
              ],
            ),
          ],
        ),
      ),
    );
  }
}