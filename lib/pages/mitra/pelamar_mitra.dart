import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:singularity/utility/supabase.client.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/mitra_pelamar_provider.dart';

class PelamarPage extends ConsumerStatefulWidget {
  const PelamarPage({super.key});

  @override
  ConsumerState<PelamarPage> createState() => _PelamarPageState();
}

class _PelamarPageState extends ConsumerState<PelamarPage> {
  String _filterStatus = "Semua";
  final Color primaryColor = const Color(0xFF19A7CE);

  Future<void> _updateStatus(int pendaftaranId, String newStatus) async {
    try {
      await supabase
          .from('pendaftaran')
          .update({'status': newStatus})
          .eq('id', pendaftaranId);

      ref.invalidate(mitraApplicantsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Status diubah jadi: ${newStatus.toUpperCase().replaceAll('_', ' ')}",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _openFile(BuildContext context, String? url) async {
    // 1. Cek apakah URL valid (tidak null dan tidak kosong)
    if (url == null || url.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("File tidak ditemukan (URL Kosong)"),
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
            content: Text("Gagal membuka file: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicantsAsync = ref.watch(mitraApplicantsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: applicantsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
              data: (allData) {
                final filteredData = allData.where((item) {
                  if (_filterStatus == "Semua") return true;
                  return (item['status'] ?? '').toString().toLowerCase() ==
                      _filterStatus.toLowerCase();
                }).toList();

                if (filteredData.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 100),
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    return _buildApplicantCard(filteredData[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Daftar Pelamar",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Kelola proses rekrutmen",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.people_alt_rounded, color: primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // UPDATED FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                    "Semua",
                    "Pending",
                    "Diterima",
                    "Berlangsung",
                    "Selesai",
                    "Ditolak",
                  ].map((status) {
                    final isSelected = _filterStatus == status;
                    return GestureDetector(
                      onTap: () => setState(() => _filterStatus = status),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.plusJakartaSans(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(Map<String, dynamic> data) {
    final mhs = data['mahasiswa'] ?? {};
    final program = data['program_magang'] ?? {};
    final status = (data['status'] ?? 'pending').toString().toLowerCase();

    // Warna Status Lengkap
    Color statusColor = Colors.orange;
    Color statusBg = Colors.orange.shade50;
    if (status == 'diterima') {
      statusColor = Colors.green;
      statusBg = Colors.green.shade50;
    }
    if (status == 'ditolak') {
      statusColor = Colors.red;
      statusBg = Colors.red.shade50;
    }
    if (status == 'berlangsung') {
      statusColor = Colors.blue;
      statusBg = Colors.blue.shade50;
    }
    if (status == 'selesai') {
      statusColor = Colors.purple;
      statusBg = Colors.purple.shade50;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetailSheet(data),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: NetworkImage(
                    mhs['foto_profil'] ??
                        'https://ui-avatars.com/api/?name=${mhs['nama']}',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mhs['nama'] ?? 'Mahasiswa',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Melamar: ${program['judul']}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status.toUpperCase().replaceAll('_', ' '),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- DETAIL SHEET (Sama persis dengan Dashboard Mitra yang baru) ---
  void _showDetailSheet(Map<String, dynamic> data) {
    final mhs = data['mahasiswa'] ?? {};
    final status = (data['status'] ?? 'pending').toString().toLowerCase();
    final cvUrl = data['file_cv'];
    final transkripUrl = data['transkrip_nilai'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
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
                CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(
                    mhs['foto_profil'] ??
                        'https://ui-avatars.com/api/?name=${mhs['nama']}',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mhs['nama'] ?? 'Unknown',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        mhs['jurusan'] ?? '-',
                        style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Dokumen Pendukung",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            _buildFileTile(
              "Lihat CV Pelamar",
              Icons.description_outlined,
              () => _openFile(context, cvUrl),
            ),
            const SizedBox(height: 8),
            _buildFileTile(
              "Lihat Transkrip Nilai",
              Icons.grade_outlined,
              () => _openFile(context, transkripUrl),
            ),

            const SizedBox(height: 30),
            Text(
              "Keputusan / Status",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            // LOGIC TOMBOL LENGKAP
            if (status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(data['id'], 'ditolak'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Tolak",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(data['id'], 'diterima'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Terima",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'diterima') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus(data['id'], 'berlangsung'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Mulai Magang",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ] else if (status == 'berlangsung') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus(data['id'], 'selesai'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Selesaikan Magang",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: status == 'selesai'
                      ? Colors.purple.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: status == 'selesai' ? Colors.purple : Colors.red,
                  ),
                ),
                child: Text(
                  status == 'selesai' ? "PROGRAM SELESAI" : "DITOLAK",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: status == 'selesai' ? Colors.purple : Colors.red,
                  ),
                ),
              ),
            ],

            if (status != 'pending') ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => _updateStatus(data['id'], 'pending'),
                  child: Text(
                    "Reset Status",
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "Belum ada pelamar",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
