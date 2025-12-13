import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:singularity/providers/mahasiswa_beranda_provider.dart';
import '../components/home_banner.dart';
import 'detail_program_magang.dart';
import 'program_magang.dart'; // Import halaman list program
import '../providers/nav_provider.dart';

// UBAH JADI STATEFUL BIAR BISA INIT STATE
class BerandaPage extends ConsumerStatefulWidget {
  const BerandaPage({super.key});

  @override
  ConsumerState<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends ConsumerState<BerandaPage> {
  @override
  void initState() {
    super.initState();
    // FIX BUG DATA LAMA NYANGKUT:
    // Setiap kali halaman ini dibuka (Login baru), kita paksa refresh datanya.
    Future.microtask(() {
      ref.invalidate(userProfileProvider);
      ref.invalidate(dashboardStatsProvider);
      ref.invalidate(recentJobsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch data terbaru
    final userProfile = ref.watch(userProfileProvider);
    final dashboardStats = ref.watch(dashboardStatsProvider);
    final recentJobs = ref.watch(recentJobsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // 1. BANNER BACKGROUND
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: HomeBannerCarousel(),
          ),

          // 3. KONTEN UTAMA (Layer Putih Melengkung)
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
                      // DASHBOARD STATISTIK
                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: dashboardStats.when(
                          data: (stats) => _buildMiniDashboard(stats),
                          loading: () => _buildLoadingDashboard(),
                          error: (_, __) => const SizedBox(),
                        ),
                      ),

                      // KATEGORI PILIHAN
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
                      _buildCategoryList(context, ref),

                      const SizedBox(height: 30),

                      // LOWONGAN TERBARU
                      _buildSectionHeader("Lowongan Terbaru", () {
                        // Reset filter dan pindah tab
                        ref.read(selectedCategoryProvider.notifier).state =
                            "Semua";
                        ref.read(navIndexProvider.notifier).state = 1;
                      }),

                      const SizedBox(height: 10),

                      // LIST LOWONGAN
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

  // --- WIDGET DASHBOARD SCROLLABLE ---
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildDashboardItem(
              stats['Pending'].toString(),
              "Pending",
              Icons.hourglass_top_rounded,
              Colors.orange,
            ),
            _buildDivider(),
            _buildDashboardItem(
              stats['Diterima'].toString(),
              "Diterima",
              Icons.check_circle_rounded,
              Colors.green,
            ),
            _buildDivider(),
            _buildDashboardItem(
              stats['Berlangsung'].toString(),
              "Magang",
              Icons.play_arrow_rounded,
              Colors.blue,
            ),
            _buildDivider(),
            _buildDashboardItem(
              stats['Selesai'].toString(),
              "Selesai",
              Icons.task_alt_rounded,
              Colors.purple,
            ),
            _buildDivider(),
            _buildDashboardItem(
              stats['Ditolak'].toString(),
              "Ditolak",
              Icons.cancel_rounded,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey.shade200,
      margin: const EdgeInsets.symmetric(horizontal: 15),
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

  // --- KATEGORI ---
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
              ref.read(selectedCategoryProvider.notifier).state =
                  cat['label'] as String;
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
          SizedBox(
            width: 70,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
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

  // --- JOB CARD ---
  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job) {
    final mitra = job['mitra'] as Map<String, dynamic>? ?? {};
    final perusahaan = mitra['nama_perusahaan'] ?? 'Perusahaan';
    final logo = job['gambar'] ?? 'https://via.placeholder.com/100';
    final alamat = mitra['alamat_perusahaan'] ?? 'Lokasi tidak tersedia';

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
