import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:singularity/providers/mahasiswa_beranda_provider.dart';
import '../utility/supabase.client.dart';

class DetailProgramPage extends ConsumerStatefulWidget {
  final int id;
  final String title;
  final String companyName;
  final String address;
  final String imageUrl;
  final String quota;
  final String description;
  final String qualification;
  final String status;
  final String deadline;

  const DetailProgramPage({
    super.key,
    required this.id,
    required this.title,
    required this.companyName,
    required this.address,
    required this.imageUrl,
    required this.quota,
    required this.description,
    required this.qualification,
    required this.status,
    required this.deadline,
  });

  @override
  ConsumerState<DetailProgramPage> createState() => _DetailProgramPageState();
}

class _DetailProgramPageState extends ConsumerState<DetailProgramPage> {
  bool _isApplying = false;
  bool _hasApplied = false;

  // State untuk File yang dipilih
  PlatformFile? _cvFile;
  PlatformFile? _transkripFile;

  final Color primaryColor = const Color(0xFF19A7CE);

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
  }

  Future<void> _checkApplicationStatus() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final mhsData = await supabase
        .from('mahasiswa')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (mhsData != null) {
      final count = await supabase
          .from('pendaftaran')
          .count()
          .eq('mahasiswa_id', mhsData['id'])
          .eq('program_magang_id', widget.id);

      if (mounted && count > 0) {
        setState(() {
          _hasApplied = true;
        });
      }
    }
  }

  // --- FUNGSI PILIH FILE ---
  Future<void> _pickFile(bool isCv) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Hanya boleh PDF biar rapi
      );

      if (result != null) {
        setState(() {
          if (isCv) {
            _cvFile = result.files.first;
          } else {
            _transkripFile = result.files.first;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengambil file: $e")));
    }
  }

  // --- FUNGSI KONFIRMASI SEBELUM UPLOAD ---
  void _showConfirmationDialog() {
    if (_cvFile == null || _transkripFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap upload CV dan Transkrip Nilai dulu!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Kirim Lamaran?",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Pastikan data kamu sudah benar. File CV dan Transkrip Nilai yang sudah dikirim TIDAK BISA diubah lagi.",
          style: GoogleFonts.plusJakartaSans(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Periksa Lagi"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              _handleApply(); // Lanjut proses lamar
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text("Ya, Kirim"),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI UPLOAD & INSERT DB ---
  Future<void> _handleApply() async {
    setState(() => _isApplying = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw "Kamu harus login dulu!";

      // 1. Cari ID Mahasiswa
      final mhsData = await supabase
          .from('mahasiswa')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (mhsData == null) throw "Lengkapi profil mahasiswa dulu ya!";

      // 2. Upload File ke Storage ('documents')
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload CV
      final cvPath = '${user.id}/${widget.id}/cv_$timestamp.pdf';
      await supabase.storage
          .from('documents')
          .upload(cvPath, File(_cvFile!.path!));
      final cvUrl = supabase.storage.from('documents').getPublicUrl(cvPath);

      // Upload Transkrip
      final transkripPath = '${user.id}/${widget.id}/transkrip_$timestamp.pdf';
      await supabase.storage
          .from('documents')
          .upload(transkripPath, File(_transkripFile!.path!));
      final transkripUrl = supabase.storage
          .from('documents')
          .getPublicUrl(transkripPath);

      // 3. Insert ke Tabel Pendaftaran (dengan URL File)
      await supabase.from('pendaftaran').insert({
        'mahasiswa_id': mhsData['id'],
        'program_magang_id': widget.id,
        'status': 'pending',
        'file_cv': cvUrl,
        'transkrip_nilai': transkripUrl,
      });

      // 4. Refresh Dashboard
      ref.invalidate(dashboardStatsProvider);

      if (mounted) {
        setState(() => _hasApplied = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lamaran dan berkas berhasil dikirim! Good luck! 🍀"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal melamar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isBuka = widget.status.toLowerCase() == 'buka';
    final statusColor = isBuka ? const Color(0xFF2E7D32) : Colors.red;
    final statusBg = isBuka ? const Color(0xFFE8F5E9) : Colors.red.shade50;
    final statusText = isBuka ? "Buka" : "Tutup";

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,

      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 320,
                  child: CustomPaint(painter: BUMNHeaderPainter()),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.2),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 170),
                  width: screenWidth * 0.85,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- KONTEN DETAIL ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.companyName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    widget.address,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF146C94).withOpacity(0.1),
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          _buildInfoColumn(
                            'Batas Pendaftaran',
                            _formatDate(widget.deadline),
                          ),
                          VerticalDivider(
                            color: Colors.grey[300],
                            thickness: 1,
                          ),
                          _buildInfoColumn('Kuota Tersedia', widget.quota),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.plusJakartaSans(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Deskripsi Program',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Kualifikasi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.qualification.split('\n').map((point) {
                    final cleanPoint = point.replaceAll('-', '').trim();
                    if (cleanPoint.isEmpty) return const SizedBox.shrink();
                    return _buildBulletPoint(cleanPoint);
                  }),

                  const SizedBox(height: 30),
                ],
              ),
            ),

            // --- FORM UPLOAD BERKAS (Hanya Muncul Jika Belum Lamar & Status Buka) ---
            if (!_hasApplied && isBuka)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Berkas Lamaran",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Upload dokumen dalam format PDF (Maks. 2MB)",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Upload CV
                    _buildUploadButton(
                      "Curriculum Vitae (CV)",
                      _cvFile,
                      () => _pickFile(true),
                    ),
                    const SizedBox(height: 12),
                    // Upload Transkrip
                    _buildUploadButton(
                      "Transkrip Nilai",
                      _transkripFile,
                      () => _pickFile(false),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),

            // --- BUTTON LAMAR ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasApplied ? 'Kamu Sudah Melamar' : 'Lamar Posisi Ini',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBuka
                          ? 'Pastikan berkas sudah lengkap sebelum mengirim.'
                          : 'Maaf, lowongan ini sudah ditutup.',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (!isBuka || _hasApplied || _isApplying)
                            ? null
                            : _showConfirmationDialog, // GANTI JADI DIALOG
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5C219),
                          disabledBackgroundColor: Colors.grey,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isApplying
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                _hasApplied
                                    ? 'Sudah Terkirim'
                                    : 'Lamar Sekarang',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget Tombol Upload
  Widget _buildUploadButton(
    String label,
    PlatformFile? file,
    VoidCallback onTap,
  ) {
    bool hasFile = file != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: hasFile ? Colors.green : Colors.grey.shade300,
            width: hasFile ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasFile
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                hasFile ? Icons.check_circle : Icons.upload_file_rounded,
                color: hasFile ? Colors.green : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasFile ? file!.name : "Belum ada file dipilih",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: hasFile ? Colors.green : Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (hasFile) const Icon(Icons.edit, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      DateTime date = DateTime.parse(isoString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return isoString;
    }
  }

  Widget _buildInfoColumn(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Icon(Icons.circle, size: 6, color: Colors.black54),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BUMNHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBlue = Paint()..color = const Color(0xFF146C94);
    final path = Path();

    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 50,
      size.width,
      size.height - 100,
    );

    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paintBlue);

    final paintDecor = Paint()..color = Colors.white.withOpacity(0.08);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.6),
      100,
      paintDecor,
    );

    final paintStroke = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.75),
      110,
      paintStroke,
    );

    canvas.save();
    canvas.translate(60, 70);
    canvas.rotate(0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 60, 60),
        const Radius.circular(12),
      ),
      paintDecor,
    );
    canvas.restore();

    canvas.drawCircle(const Offset(80, 160), 15, paintDecor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
