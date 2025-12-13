import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:singularity/providers/mitra_dashboard_provider.dart';
import 'package:singularity/utility/supabase.client.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/nav_provider.dart';

class DashboardMitra extends ConsumerWidget {
  const DashboardMitra({super.key});

  final Color primaryColor = const Color(0xFF19A7CE);

  // --- LOGIC UPDATE STATUS ---
  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    int pendaftaranId,
    String newStatus,
  ) async {
    try {
      await supabase
          .from('pendaftaran')
          .update({'status': newStatus})
          .eq('id', pendaftaranId);

      ref.invalidate(mitraDashboardProvider);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Status diubah menjadi: ${newStatus.toUpperCase().replaceAll('_', ' ')}",
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted)
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
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(mitraDashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (data) {
          final profile = data.mitraProfile;

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(mitraDashboardProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, profile),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. STATISTIK CARDS (Update: Tambah 1 Card)
                        Transform.translate(
                          offset: const Offset(0, -40),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none, // Biar shadow gak kepotong
                            child: Row(
                              children: [
                                _buildStatCard(
                                  "Loker Aktif",
                                  data.activeLoker.toString(),
                                  Colors.blue,
                                  Icons.work_outline,
                                ),
                                const SizedBox(width: 12),
                                _buildStatCard(
                                  "Pelamar",
                                  data.totalPelamar.toString(),
                                  Colors.orange,
                                  Icons.people_outline,
                                ),
                                const SizedBox(width: 12),
                                _buildStatCard(
                                  "Butuh Review",
                                  data.needReview.toString(),
                                  Colors.red,
                                  Icons.rate_review_outlined,
                                ),
                                const SizedBox(width: 12),
                                // NEW STAT: Magang Aktif
                                _buildStatCard(
                                  "Aktif Magang",
                                  data.activeInterns.toString(),
                                  Colors.teal,
                                  Icons.badge_outlined,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 3. PELAMAR TERBARU
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Pelamar Terbaru",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.read(navIndexProvider.notifier).state = 3;
                              },
                              child: Text(
                                "Lihat Semua",
                                style: GoogleFonts.plusJakartaSans(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        if (data.recentApplicants.isEmpty)
                          _buildEmptyState()
                        else
                          ...data.recentApplicants.map(
                            (app) => _buildApplicantTile(context, ref, app),
                          ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS ---
  // (Header sama persis, saya ringkas biar hemat token, timpa aja pake yang sebelumnya kalau mau, atau pakai ini yang clean)
  Widget _buildHeader(BuildContext context, Map<String, dynamic> profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 60),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        image: const DecorationImage(
          image: AssetImage('assets/images/pattern_bg.png'),
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              image: DecorationImage(
                image: NetworkImage(
                  profile['logo_perusahaan'] ??
                      'https://via.placeholder.com/150',
                ),
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
                  "Halo, HRD!",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  profile['nama_perusahaan'] ?? 'Nama Perusahaan',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Belum ada notifikasi")),
            ),
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String count,
    Color color,
    IconData icon,
  ) {
    // Ubah jadi Container fix width biar rapi di scroll horizontal
    return Container(
      width: 110, // Lebar fix
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantTile(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> app,
  ) {
    final mhs = app['mahasiswa'] ?? {};
    final program = app['program_magang'] ?? {};
    final status = (app['status'] ?? 'pending').toString().toLowerCase();

    Color statusColor = Colors.orange;
    if (status == 'diterima') statusColor = Colors.green;
    if (status == 'ditolak') statusColor = Colors.red;
    if (status == 'berlangsung') statusColor = Colors.blue;
    if (status == 'selesai') statusColor = Colors.purple;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade100,
          backgroundImage: NetworkImage(
            mhs['foto_profil'] ??
                'https://ui-avatars.com/api/?name=${mhs['nama']}',
          ),
        ),
        title: Text(
          mhs['nama'] ?? 'Mahasiswa',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Melamar: ${program['judul']}",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status.toUpperCase().replaceAll('_', ' '),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => _showDetailSheet(context, ref, app),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(
            "Belum ada pelamar masuk",
            style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // --- DETAIL SHEET (UPDATED FLOW) ---
  void _showDetailSheet(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> data,
  ) {
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

            // Header Profile
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
              context,
              "Lihat CV Pelamar",
              Icons.description_outlined,
              () => _openFile(context, cvUrl),
            ),
            const SizedBox(height: 8),
            _buildFileTile(
              context,
              "Lihat Transkrip Nilai",
              Icons.grade_outlined,
              () => _openFile(context, transkripUrl),
            ),

            const SizedBox(height: 30),

            // --- ACTION BUTTONS (FLOW UPDATE) ---
            Text(
              "Keputusan / Status",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            // CASE 1: PENDING (Terima / Tolak)
            if (status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _updateStatus(context, ref, data['id'], 'ditolak'),
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
                      onPressed: () =>
                          _updateStatus(context, ref, data['id'], 'diterima'),
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
            ]
            // CASE 2: DITERIMA -> MULAI MAGANG
            else if (status == 'diterima') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _updateStatus(context, ref, data['id'], 'berlangsung'),
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
                    "Mulai Magang (Set Aktif)",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Mahasiswa ini sudah diterima, mulai magang saat onboarding.",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ]
            // CASE 3: BERLANGSUNG -> SELESAI
            else if (status == 'berlangsung') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _updateStatus(context, ref, data['id'], 'selesai'),
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
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Tandai selesai jika periode magang sudah berakhir.",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ]
            // CASE 4: SELESAI / DITOLAK (Info Only)
            else ...[
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
                  status == 'selesai'
                      ? "PROGRAM MAGANG SELESAI"
                      : "LAMARAN DITOLAK",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: status == 'selesai' ? Colors.purple : Colors.red,
                  ),
                ),
              ),
            ],

            // RESET BUTTON (Kecil di bawah, buat emergency salah klik)
            if (status != 'pending') ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () =>
                      _updateStatus(context, ref, data['id'], 'pending'),
                  child: Text(
                    "Reset Status ke Pending",
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

  Widget _buildFileTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
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
        child: Icon(icon, color: const Color(0xFF19A7CE)),
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
}
