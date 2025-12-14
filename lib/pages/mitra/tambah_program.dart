import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:singularity/providers/mitra_lowongan_provider.dart';
import 'package:singularity/utility/supabase.client.dart';
import '../../providers/nav_provider.dart';

class TambahProgram extends ConsumerStatefulWidget {
  final Map<String, dynamic>? jobData;

  const TambahProgram({super.key, this.jobData});

  @override
  ConsumerState<TambahProgram> createState() => _TambahProgramState();
}

class _TambahProgramState extends ConsumerState<TambahProgram> {
  bool _isLoading = false;
  bool _isEditMode = false;

  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _kualifikasiController = TextEditingController();
  final _kuotaController = TextEditingController();

  DateTime? _batasPendaftaran;
  DateTime? _awalMagang;
  DateTime? _selesaiMagang;

  String _selectedCategory = "Web Developer";
  final List<String> _categories = [
    "Web Developer",
    "Mobile Developer",
    "UI/UX Designer",
    "DevOps",
    "CyberSecurity",
  ];

  File? _bannerFile; // File baru yang dipilih
  String? _currentBannerUrl; // URL lama (buat preview pas edit)

  final ImagePicker _picker = ImagePicker();
  final Color primaryColor = const Color(0xFF19A7CE);

  @override
  void initState() {
    super.initState();
    // Cek apakah ini mode edit?
    if (widget.jobData != null) {
      _isEditMode = true;
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final data = widget.jobData!;
    _judulController.text = data['judul'] ?? '';
    _deskripsiController.text = data['deskripsi_program'] ?? '';
    _kualifikasiController.text = data['kualifikasi'] ?? '';
    _kuotaController.text = (data['kuota'] ?? 0).toString();

    // Load Kategori (Pastikan value ada di list, kalau gak default)
    if (_categories.contains(data['kategori'])) {
      _selectedCategory = data['kategori'];
    }

    // Load Tanggal
    try {
      if (data['batas_pendaftaran'] != null)
        _batasPendaftaran = DateTime.parse(data['batas_pendaftaran']);
      if (data['awal_magang'] != null)
        _awalMagang = DateTime.parse(data['awal_magang']);
      if (data['selesai_magang'] != null)
        _selesaiMagang = DateTime.parse(data['selesai_magang']);
    } catch (e) {
      debugPrint("Error parsing date: $e");
    }

    // Load Gambar
    _currentBannerUrl = data['gambar'];
  }

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

  Future<void> _selectDate(BuildContext context, String type) async {
    // Tanggal awal disesuaikan: Kalau edit, boleh tanggal lama. Kalau baru, mulai besok.
    final initialDate = _isEditMode
        ? (_batasPendaftaran ?? DateTime.now())
        : DateTime.now().add(const Duration(days: 1));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: primaryColor)),
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

  Future<void> _handleSubmit() async {
    if (_judulController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        _kuotaController.text.isEmpty ||
        _batasPendaftaran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi data wajib!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      String? bannerUrl = _currentBannerUrl; // Default pake URL lama

      // Kalau user upload gambar baru, kita upload dulu
      if (_bannerFile != null) {
        final fileExt = _bannerFile!.path.split('.').last;
        final fileName =
            'loker/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        await supabase.storage.from('avatars').upload(fileName, _bannerFile!);
        bannerUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
      }

      final dataToSave = {
        'judul': _judulController.text,
        'deskripsi_program': _deskripsiController.text,
        'kualifikasi': _kualifikasiController.text,
        'kuota': int.parse(_kuotaController.text),
        'kategori': _selectedCategory,
        'batas_pendaftaran': _batasPendaftaran!.toIso8601String(),
        'awal_magang': _awalMagang!.toIso8601String(),
        'selesai_magang': _selesaiMagang!.toIso8601String(),
        'gambar': bannerUrl,
      };

      if (_isEditMode) {
        // --- LOGIC UPDATE ---
        await supabase
            .from('program_magang')
            .update(dataToSave)
            .eq('id', widget.jobData!['id']); // Update berdasarkan ID

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Perubahan disimpan!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Tutup halaman edit
        }
      } else {
        // --- LOGIC INSERT (BARU) ---
        // Ambil Mitra ID dulu
        final mitraRes = await supabase
            .from('mitra')
            .select('id')
            .eq('user_id', user.id)
            .single();
        final mitraId = mitraRes['id'];

        dataToSave['mitra_id'] = mitraId;
        dataToSave['status_magang'] = 'buka';

        await supabase.from('program_magang').insert(dataToSave);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Lowongan diterbitkan!"),
              backgroundColor: Colors.green,
            ),
          );
          // Reset form
          _judulController.clear();
          setState(() => _bannerFile = null);
          // Pindah ke Tab Lokerku
          ref.read(navIndexProvider.notifier).state = 1;
        }
      }

      ref.invalidate(mitraJobsProvider); // Refresh list
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
        centerTitle: true,
        // Kalau edit mode, ada tombol back. Kalau tambah (dari navbar), gak ada.
        leading: _isEditMode
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          _isEditMode ? "Edit Lowongan" : "Buat Lowongan Baru",
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // BANNER UPLOAD
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                  // Prioritas Gambar: File Baru > URL Lama > Kosong
                  image: _bannerFile != null
                      ? DecorationImage(
                          image: FileImage(_bannerFile!),
                          fit: BoxFit.cover,
                        )
                      : (_currentBannerUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_currentBannerUrl!),
                                fit: BoxFit.cover,
                              )
                            : null),
                ),
                child: (_bannerFile == null && _currentBannerUrl == null)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 30,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Upload Banner",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          Positioned(
                            right: 10,
                            top: 10,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 18,
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    "Judul Posisi",
                    _judulController,
                    Icons.work_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    "Kuota",
                    _kuotaController,
                    Icons.people_outline,
                    isNumber: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              "Kategori",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
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
                  onSelected: (val) => setState(() => _selectedCategory = cat),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            Text(
              "Jadwal Program",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            _buildDatePickerTile(
              "Batas Pendaftaran",
              _batasPendaftaran,
              () => _selectDate(context, 'batas'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildDatePickerTile(
                    "Mulai",
                    _awalMagang,
                    () => _selectDate(context, 'awal'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDatePickerTile(
                    "Selesai",
                    _selesaiMagang,
                    () => _selectDate(context, 'selesai'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildTextArea("Deskripsi Pekerjaan", _deskripsiController),
            const SizedBox(height: 16),
            _buildTextArea("Kualifikasi", _kualifikasiController),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isEditMode ? "Simpan Perubahan" : "Terbitkan Lowongan",
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
      ),
    );
  }

  // Helper Widget (sama kayak sebelumnya)
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
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
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
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
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
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

  Widget _buildDatePickerTile(
    String label,
    DateTime? date,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null ? primaryColor : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? "${date.day}/${date.month}/${date.year}"
                      : "Pilih Tgl",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: date != null ? Colors.black87 : Colors.grey.shade400,
                  ),
                ),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: date != null ? primaryColor : Colors.grey.shade300,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
