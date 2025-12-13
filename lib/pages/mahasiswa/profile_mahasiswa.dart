import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:singularity/pages/mahasiswa/settings_mahasiswa.dart';
import 'package:singularity/providers/mahasiswa_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileMahasiswa extends ConsumerStatefulWidget {
  const ProfileMahasiswa({super.key});
  @override
  ConsumerState<ProfileMahasiswa> createState() => _ProfileMahasiswaState();
}

class _ProfileMahasiswaState extends ConsumerState<ProfileMahasiswa> {
  final Color primaryColor = const Color(0xFF19A7CE);
  final Color bgColor = const Color(0xFFF8F9FA);
  @override
  void initState() {
    super.initState();
    // Paksa refresh data profil & history setiap kali halaman ini dimuat pertama kali
    Future.microtask(() {
      ref.invalidate(userProfileDetailProvider);
      ref.invalidate(applicationHistoryProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileDetailProvider);
    final historyAsync = ref.watch(applicationHistoryProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userProfileDetailProvider);
          ref.invalidate(applicationHistoryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 1. HEADER
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  _buildHeaderBackground(context),
                  Positioned(
                    top: 100,
                    left: 24,
                    right: 24,
                    child: profileAsync.when(
                      data: (mhs) => _buildMainProfileCard(mhs),
                      loading: () => _buildLoadingCard(),
                      error: (err, _) => _buildErrorCard("Gagal memuat profil"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 100),

              // 2. KONTEN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: profileAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox(),
                  data: (mhs) {
                    if (mhs == null)
                      return const Center(child: Text("Profil belum diisi"));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Informasi Pribadi"),
                        const SizedBox(height: 12),
                        _buildBioContainer([
                          _buildBioRow(
                            Icons.person_outline,
                            "Gender",
                            mhs['gender'] ?? '-',
                          ),
                          _buildDivider(),
                          _buildBioRow(
                            Icons.cake_outlined,
                            "Tempat, Tgl Lahir",
                            "${mhs['tempat_lahir'] ?? '-'}, ${_formatDate(mhs['tanggal_lahir'])}",
                          ),
                          _buildDivider(),
                          _buildBioRow(
                            Icons.phone_outlined,
                            "No. Handphone",
                            mhs['no_hp'] ?? '-',
                          ),
                        ]),

                        const SizedBox(height: 24),

                        _buildSectionTitle("Alamat Domisili"),
                        const SizedBox(height: 12),
                        _buildBioContainer([
                          _buildBioRow(
                            Icons.location_on_outlined,
                            "Jalan",
                            mhs['alamat'] ?? '-',
                          ),
                          _buildDivider(),
                          _buildBioRow(
                            Icons.holiday_village_outlined,
                            "Desa - Kecamatan",
                            "${mhs['desa'] ?? '-'} - ${mhs['kecamatan'] ?? '-'}",
                          ),
                          _buildDivider(),
                          _buildBioRow(
                            Icons.map_outlined,
                            "Kabupaten - Provinsi",
                            "${mhs['kabupaten'] ?? '-'} - ${mhs['provinsi'] ?? '-'}",
                          ),
                        ]),

                        const SizedBox(height: 24),

                        _buildSectionTitle("Riwayat Lamaran"),
                        const SizedBox(height: 12),

                        historyAsync.when(
                          data: (history) => _buildHistoryTable(
                            context,
                            history,
                          ), // Kirim Context
                          loading: () =>
                              const Center(child: LinearProgressIndicator()),
                          error: (_, __) => const Text("Gagal memuat riwayat"),
                        ),

                        const SizedBox(height: 120),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LOGIC BOTTOM SHEET DETAIL LAMARAN ---
  void _showApplicationDetail(BuildContext context, Map<String, dynamic> data) {
    final program = data['program_magang'] ?? {};
    final mitra = program['mitra'] ?? {};

    final posisi = program['judul'] ?? 'Unknown';
    final namaMitra = mitra['nama_perusahaan'] ?? 'Unknown';
    final status = data['status'] ?? 'pending';
    final tanggal = _formatDate(data['created_at']);
    final cvUrl = data['file_cv'];
    final transkripUrl = data['transkrip_nilai'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header Sheet
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.work_rounded, color: primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          posisi,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          namaMitra,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(status),
                ],
              ),
              const SizedBox(height: 24),

              const Divider(),
              const SizedBox(height: 16),

              Text(
                "Tanggal Melamar: $tanggal",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),

              // TOMBOL FILE
              Text(
                "Dokumen Terkirim",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              _fileTile(context, "Curriculum Vitae (CV)", cvUrl),
              const SizedBox(height: 10),
              _fileTile(context, "Transkrip Nilai", transkripUrl),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _fileTile(BuildContext context, String label, String? url) {
    return InkWell(
      onTap: () => _openFile(context, label, url),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.insert_drive_file_outlined,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.open_in_new, size: 18, color: primaryColor),
          ],
        ),
      ),
    );
  }

  Future<void> _openFile(
    BuildContext context,
    String label,
    String? url,
  ) async {
    // 1. Cek apakah URL valid (tidak null dan tidak kosong)
    if (url == null || url.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$label tidak ditemukan (URL Kosong)"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      Uri uri;
      if (Platform.isAndroid && url.toLowerCase().contains('.pdf')) {
        // Kita encode URL aslinya biar aman masuk ke parameter query
        final encodedUrl = Uri.encodeComponent(url);
        uri = Uri.parse("https://docs.google.com/viewer?url=$encodedUrl");
      } else {
        // Untuk iOS atau bukan PDF (misal gambar), buka link aslinya
        uri = Uri.parse(url);
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      // Tangkap error kodingan (misal URL formatnya aneh)
      debugPrint("Error launching URL: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal membuka $label: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- TABEL ---
  Widget _buildHistoryTable(
    BuildContext context,
    List<Map<String, dynamic>> historyData,
  ) {
    if (historyData.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Center(
          child: Text(
            "Belum ada lamaran",
            style: GoogleFonts.plusJakartaSans(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(flex: 3, child: _tableHeader("Posisi")),
                Expanded(flex: 2, child: _tableHeader("Status")),
                // Kasih sedikit space biar sejajar sama icon chevron di bawah
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 20.0,
                    ), // Kompensasi visual untuk icon chevron
                    child: _tableHeader("Tanggal", align: TextAlign.end),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

          ...historyData.map((data) {
            final program = data['program_magang'] ?? {};
            final mitra = program['mitra'] ?? {};
            final posisi = program['judul'] ?? 'Unknown';
            final namaMitra = mitra['nama_perusahaan'] ?? 'Unknown';
            final status = data['status'] ?? 'pending';
            final tanggal = _formatDate(data['created_at']);

            return InkWell(
              // BUNGKUS DENGAN INKWELL BIAR BISA DIKLIK
              onTap: () => _showApplicationDetail(context, data),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                posisi,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                namaMitra,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Expanded(flex: 2, child: _buildStatusBadge(status)),
                        Expanded(
                          flex: 2,
                          child: Text(
                            tanggal,
                            textAlign: TextAlign.end,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        // INDIKATOR KLIK (Panah Kecil)
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  if (data != historyData.last)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF5F5F5),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // --- HELPER FUNCTION & WIDGET LAINNYA ---
  String _formatDate(String? isoString) {
    if (isoString == null) return '-';
    try {
      final date = DateTime.parse(isoString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return isoString;
    }
  }

  Widget _buildHeaderBackground(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profil Saya',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsMahasiswa(),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMainProfileCard(Map<String, dynamic>? mhs) {
    final nama = mhs?['nama'] ?? 'Mahasiswa';
    final nim = mhs?['nim'] ?? '-';
    final jurusan = mhs?['jurusan'] ?? '-';
    final univ = mhs?['universitas'] ?? '-';
    final foto =
        mhs?['foto_profil'] ?? 'https://ui-avatars.com/api/?name=$nama';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(0.1),
              image: DecorationImage(
                image: NetworkImage(foto),
                fit: BoxFit.cover,
                onError: (_, __) {},
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nim,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                Text(
                  "$jurusan • $univ",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Mahasiswa Aktif",
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorCard(String msg) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(msg, style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildBioContainer(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildBioRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text, {TextAlign align = TextAlign.start}) {
    return Text(
      text,
      textAlign: align,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade400,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bg;
    final s = status.toLowerCase();

    // UPDATE LOGIC WARNA STATUS
    if (s == 'diterima') {
      color = Colors.green;
      bg = Colors.green.shade50;
    } else if (s == 'ditolak') {
      color = Colors.red;
      bg = Colors.red.shade50;
    } else if (s == 'berlangsung') {
      color = Colors.blue;
      bg = Colors.blue.shade50;
    } else if (s == 'selesai') {
      color = Colors.purple;
      bg = Colors.purple.shade50;
    } else {
      // Default / Pending
      color = Colors.orange;
      bg = Colors.orange.shade50;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        s[0].toUpperCase() + s.substring(1),
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 42),
      child: Divider(color: Colors.grey.shade100),
    );
  }
}
