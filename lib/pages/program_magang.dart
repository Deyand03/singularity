import 'dart:async'; // Butuh ini buat Timer
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/program_provider.dart';
import '../providers/nav_provider.dart';
import 'detail_program_magang.dart';
import 'dart:math';

class ProgramMagang extends ConsumerStatefulWidget {
  final String? initialCategory;
  const ProgramMagang({super.key, this.initialCategory});

  @override
  ConsumerState<ProgramMagang> createState() => _ProgramMagangState();
}

class _ProgramMagangState extends ConsumerState<ProgramMagang> {
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  // Search State
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  Timer? _debounce; // Timer untuk delay pencarian

  final List<String> _categories = [
    "Semua",
    "Web Developer",
    "Mobile Developer",
    "UI/UX Designer",
    "DevOps",
    "CyberSecurity",
  ];

  @override
  void initState() {
    super.initState();
    // Kalau ada kategori dari luar (misal dari Beranda), set controller
    // Note: Provider kategori udah dihandle di build via ref.watch
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel(); // Matikan timer kalau halaman ditutup
    super.dispose();
  }

  // LOGIKA PENCARIAN (DELAY 1 DETIK)
  void _onSearchChanged(String query) {
    // Kalau user ngetik lagi sebelum 1 detik, batalin timer sebelumnya
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Mulai timer baru
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        _searchQuery = query;
        _currentPage = 1; // Reset ke halaman 1 kalau hasil pencarian berubah
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Ambil Kategori dari Global Provider
    final selectedCategory = ref.watch(selectedCategoryProvider);

    // 2. Buat Filter Gabungan (Kategori + Search Query)
    final filter = ProgramFilter(
      category: selectedCategory,
      query: _searchQuery,
    );

    // 3. Minta Data ke Provider dengan Filter
    final programAsyncValue = ref.watch(programListProvider(filter));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header sekarang punya akses ke fungsi search
          _buildCustomHeader(onSearch: _onSearchChanged),

          Expanded(
            child: programAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
              data: (allPrograms) {
                if (allPrograms.isEmpty) return _buildEmptyState(ref);

                int totalPages = (allPrograms.length / _itemsPerPage).ceil();
                if (_currentPage > totalPages && totalPages > 0)
                  _currentPage = 1;

                int startIndex = (_currentPage - 1) * _itemsPerPage;
                int endIndex = min(
                  startIndex + _itemsPerPage,
                  allPrograms.length,
                );
                final currentData = allPrograms.sublist(startIndex, endIndex);

                return ListView(
                  padding: const EdgeInsets.only(top: 0, bottom: 100),
                  children: [
                    const SizedBox(height: 10),
                    _buildCategoryList(ref, selectedCategory),
                    const SizedBox(height: 10),

                    // Tampilkan Hasil Pencarian (Feedback Text)
                    if (_searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Text(
                          "Menampilkan hasil untuk \"$_searchQuery\"",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                    ...currentData.map((program) {
                      final mitra = program['mitra'] ?? {};
                      return ProgramCard(
                        companyName: mitra['nama_perusahaan'] ?? 'Unknown',
                        programTitle: program['judul'] ?? 'No Title',
                        address: mitra['alamat_perusahaan'] ?? '-',
                        quota: program['kuota'].toString(),
                        imageUrl:
                            program['gambar'] ??
                            'https://via.placeholder.com/200',
                        category: program['kategori'] ?? '-',
                        status: program['status_magang'] ?? 'tutup',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailProgramPage(
                                id: program['id'],
                                title: program['judul'],
                                companyName: mitra['nama_perusahaan'],
                                address: mitra['alamat_perusahaan'],
                                imageUrl: program['gambar'],
                                quota: program['kuota'].toString(),
                                description:
                                    program['deskripsi_program'] ?? '-',
                                qualification: program['kualifikasi'] ?? '-',
                                status: program['status_magang'] ?? 'tutup',
                                deadline:
                                    program['batas_pendaftaran'] ??
                                    DateTime.now().toString(),
                              ),
                            ),
                          );
                        },
                      );
                    }),

                    if (allPrograms.isNotEmpty)
                      _buildPaginationControl(totalPages),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(WidgetRef ref) {
    final selectedCategory = ref.read(selectedCategoryProvider);
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildCategoryList(ref, selectedCategory),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 60,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 10),
              Text(
                "Tidak ditemukan lowongan",
                style: GoogleFonts.plusJakartaSans(color: Colors.grey),
              ),
              if (_searchQuery.isNotEmpty)
                Text(
                  "untuk \"$_searchQuery\"",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(WidgetRef ref, String currentCategory) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: _categories.map((category) {
          bool isSelected = currentCategory == category;
          return GestureDetector(
            onTap: () {
              ref.read(selectedCategoryProvider.notifier).state = category;
              setState(() => _currentPage = 1);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF19A7CE) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade200,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF19A7CE).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                category,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Custom Header yang menerima fungsi onChanged
  Widget _buildCustomHeader({required Function(String) onSearch}) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF19A7CE),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (Navigator.canPop(context))
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temukan Peluang',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Program Magang',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController, // Connect controller
              onChanged: onSearch, // Connect fungsi debounce
              decoration: InputDecoration(
                hintText: 'Cari posisi atau perusahaan...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF19A7CE),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControl(int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: _currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _currentPage > 1 ? Colors.white : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _currentPage > 1
                      ? const Color(0xFF19A7CE)
                      : Colors.grey.shade300,
                ),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                color: _currentPage > 1
                    ? const Color(0xFF19A7CE)
                    : Colors.grey.shade400,
              ),
            ),
          ),
          Text(
            'Halaman $_currentPage dari $totalPages',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          InkWell(
            onTap: _currentPage < totalPages
                ? () => setState(() => _currentPage++)
                : null,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _currentPage < totalPages
                    ? Colors.white
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _currentPage < totalPages
                      ? const Color(0xFF19A7CE)
                      : Colors.grey.shade300,
                ),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: _currentPage < totalPages
                    ? const Color(0xFF19A7CE)
                    : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ... ProgramCard sama persis, gak berubah ...
class ProgramCard extends StatelessWidget {
  final String companyName;
  final String programTitle;
  final String address;
  final String quota;
  final String imageUrl;
  final String category;
  final String status;
  final VoidCallback onTap;

  const ProgramCard({
    super.key,
    required this.companyName,
    required this.programTitle,
    required this.address,
    required this.quota,
    required this.imageUrl,
    required this.category,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBuka = status.toLowerCase() == 'buka';
    final statusColor = isBuka ? Colors.green : Colors.red;
    final statusBg = isBuka ? Colors.green.shade50 : Colors.red.shade50;
    final statusText = isBuka ? "Buka" : "Tutup";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category,
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
                              borderRadius: BorderRadius.circular(8),
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
                        programTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        companyName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
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
                              address,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                            "$quota Slot",
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
}
