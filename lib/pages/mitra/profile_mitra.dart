import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/mitra_profile_provider.dart';
import 'settings_mitra.dart';

class ProfileMitra extends ConsumerWidget {
  const ProfileMitra({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(mitraProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      // Stack Global: Konten Scroll di bawah, Tombol Navigasi Melayang di atas
      body: Stack(
        children: [
          // 1. KONTEN SCROLLABLE
          profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text("Error: $err")),
            data: (mitra) {
              if (mitra == null)
                return const Center(child: Text("Data mitra tidak ditemukan"));

              final bannerUrl = mitra['banner_perusahaan'];
              final logoUrl =
                  mitra['logo_perusahaan'] ?? 'https://via.placeholder.com/150';

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // A. BANNER (Layer Terbawah)
                        Container(
                          height: 280, // Tinggi banner
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            image: bannerUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(bannerUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: bannerUrl == null
                              ? const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                )
                              : null,
                        ),

                        // B. GRADIENT OVERLAY (Biar tombol back kelihatan jelas)
                        Container(
                          height: 280,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.5), // Gelap di atas
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.4],
                            ),
                          ),
                        ),

                        // C. BODY CONTENT (Layer Tengah - Background Putih)
                        Container(
                          margin: const EdgeInsets.only(
                            top: 240,
                          ), // Mulai putihnya di sini
                          padding: const EdgeInsets.fromLTRB(
                            24,
                            60,
                            24,
                            100,
                          ), // Padding top 60 buat ruang logo
                          decoration: const BoxDecoration(
                            color: Colors.white,
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
                              // NAMA PERUSAHAAN (Centered)
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      mitra['nama_perusahaan'] ??
                                          'Nama Perusahaan',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.verified,
                                            color: Colors.blue,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Mitra Terverifikasi",
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),

                              // INFO DETAIL
                              _buildInfoSection(
                                "Tentang Perusahaan",
                                mitra['deskripsi'] ?? 'Belum ada deskripsi.',
                              ),
                              const SizedBox(height: 24),
                              _buildInfoSection(
                                "Alamat",
                                mitra['alamat_perusahaan'] ??
                                    'Alamat belum diatur.',
                              ),

                              const SizedBox(height: 30),

                              // STATISTIK KECIL
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      "Bergabung",
                                      _formatDate(mitra['created_at']),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: Colors.grey.shade300,
                                    ),
                                    _buildStatItem("Status", "Aktif"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // D. LOGO FLOATING (Layer Paling Atas - Pasti Nimpa Banner)
                        Positioned(
                          top:
                              190, // Posisi Logo (240 - 50 = Setengah di banner, setengah di putih)
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              image: DecorationImage(
                                image: NetworkImage(logoUrl),
                                fit: BoxFit.cover,
                                onError: (_, __) {},
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // 2. FLOATING NAVIGATION BUTTONS (Selalu di atas segalanya)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Tombol Edit
                    _buildCircleBtn(
                      icon: Icons.settings_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsMitra(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tombol Bulat Transparan
  Widget _buildCircleBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25), // Background hitam transparan
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '-';
    try {
      final date = DateTime.parse(isoString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return '-';
    }
  }
}
