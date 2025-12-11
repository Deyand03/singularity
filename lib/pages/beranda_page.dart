import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:singularity/pages/detail_program_magang.dart';
import 'package:singularity/providers/common.provider.dart'; // Import Provider yang tadi dibuat
import 'package:singularity/providers/nav_provider.dart';
import '../components/home_banner.dart';
import 'program_magang.dart';

// UBAH JADI CONSUMER WIDGET
class BerandaPage extends ConsumerWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. WATCH PROVIDERS (Dengerin data)
    final dashboardStats = ref.watch(dashboardStatsProvider);
    final recentJobs = ref.watch(recentJobsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // --- BACKGROUND & HEADER USER ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Stack(
              children: [
                const HomeBannerCarousel(), // Banner Gambar
              ],
            ),
          ),

          // --- KONTEN UTAMA (Layer Putih) ---
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 240, bottom: 120),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. DASHBOARD STATISTIK
                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: dashboardStats.when(
                          data: (stats) => _buildMiniDashboard(stats),
                          loading: () =>
                              _buildLoadingDashboard(), // Skeleton Loading
                          error: (_, __) => const SizedBox(),
                        ),
                      ),

                      // 2. KATEGORI PILIHAN
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          "Kategori Pilihan",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pass context buat navigasi
                      _buildCategoryList(context, ref),

                      const SizedBox(height: 30),

                      // 3. LOWONGAN TERBARU
                      _buildSectionHeader("Lowongan Terbaru", () {
                        // Reset kategori ke "Semua" kalau klik "Lihat Semua"
                        ref.read(selectedCategoryProvider.notifier).state =
                            "Semua";
                        // Pindah Tab
                        ref.read(navIndexProvider.notifier).state = 1;
                      }),

                      const SizedBox(height: 10),

                      // 4. LIST LOWONGAN (REAL DATA)
                      recentJobs.when(
                        data: (jobs) {
                          if (jobs.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text("Belum ada lowongan nih."),
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: jobs.length,
                            itemBuilder: (context, index) {
                              return _buildJobCard(context, jobs[index]);
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, stack) =>
                            Center(child: Text("Error: $err")),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET DASHBOARD ---
  Widget _buildMiniDashboard(Map<String, int> stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF19A7CE).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDashboardItem(
            stats['Pending'].toString(),
            "Pending",
            Icons.hourglass_top_rounded,
            Colors.orange,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildDashboardItem(
            stats['Diterima'].toString(),
            "Diterima",
            Icons.check_circle_rounded,
            Colors.green,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildDashboardItem(
            stats['Ditolak'].toString(),
            "Ditolak",
            Icons.cancel_rounded,
            Colors.red,
          ),
        ],
      ),
    );
  }

  // Loading state buat dashboard biar cantik
  Widget _buildLoadingDashboard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDashboardItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // --- WIDGET KATEGORI ---
  Widget _buildCategoryList(BuildContext context, WidgetRef ref) {
    final categories = [
      {"label": "Web Developer", "icon": Icons.code, "color": Colors.blue},
      {
        "label": "Mobile Developer",
        "icon": Icons.phone_android,
        "color": Colors.orange,
      },
      {"label": "UI/UX Designer", "icon": Icons.brush, "color": Colors.purple},
      {"label": "DevOps", "icon": Icons.cloud_sync, "color": Colors.teal},
      {"label": "CyberSecurity", "icon": Icons.security, "color": Colors.red},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: categories.map((cat) {
          return GestureDetector(
            onTap: () {
              // 1. Set Kategori di Provider Global
              ref.read(selectedCategoryProvider.notifier).state =
                  cat['label'] as String;

              // 2. Pindah Tab ke Halaman Program (Index 1)
              ref.read(navIndexProvider.notifier).state = 1;
            },
            child: _buildCategoryItem(
              cat['label'] as String,
              cat['icon'] as IconData,
              cat['color'] as Color,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
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
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          // Bungkus teks biar gak overflow kalo kepanjangan
          SizedBox(
            width: 70,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2, // Maksimal 2 baris
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET LOWONGAN CARD (DATA ASLI) ---
  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job) {
    // Ambil data relasi
    final mitra = job['mitra'] as Map<String, dynamic>? ?? {};
    final perusahaan = mitra['nama_perusahaan'] ?? 'Perusahaan';
    final logo = job['gambar'] ?? 'https://via.placeholder.com/100';
    final alamat = mitra['alamat_perusahaan'] ?? 'Lokasi tidak tersedia';

    // Status Logic
    final status = job['status_magang'] ?? 'tutup';
    final isBuka = status.toLowerCase() == 'buka';
    final statusColor = isBuka ? Colors.green : Colors.red;
    final statusBg = isBuka ? Colors.green.shade50 : Colors.red.shade50;
    final statusText = isBuka ? "Buka" : "Tutup";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
          onTap: () {
            // NAVIGASI KE DETAIL (Kirim Data Lengkap)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailProgramPage(
                  id: job['id'],
                  title: job['judul'],
                  companyName: perusahaan,
                  address: alamat,
                  imageUrl: job['gambar'] ?? 'https://via.placeholder.com/300',
                  quota: job['kuota'].toString(),
                  description: job['deskripsi_program'] ?? '-',
                  qualification: job['kualifikasi'] ?? '-',
                  status: status,
                  deadline:
                      job['batas_pendaftaran'] ?? DateTime.now().toString(),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Align Top
              children: [
                // 1. LOGO PERUSAHAAN
                Container(
                  width: 70, // Lebih gede dikit biar sama kayak halaman list
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(logo),
                      fit: BoxFit.cover,
                      onError: (e, s) {},
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // 2. INFO TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Kategori & Status (NEW FEATURE)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Badge Kategori
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF19A7CE).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              job['kategori'] ?? 'Umum',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF19A7CE),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Badge Status
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: statusColor.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  statusText,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: statusColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        job['judul'] ?? 'Posisi Magang',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        perusahaan,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // BADGE LOKASI & KUOTA (NEW FEATURE)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              alamat,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Kuota
                          Icon(
                            Icons.people_outline,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${job['kuota']} Slot",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: onPressed,
            child: Text(
              "Lihat Semua",
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF19A7CE),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
