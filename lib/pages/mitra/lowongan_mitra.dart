import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:singularity/pages/mitra/tambah_program.dart';
import 'package:singularity/providers/mitra_lowongan_provider.dart';
import 'package:singularity/utility/supabase.client.dart';

class LowonganMitra extends ConsumerStatefulWidget {
  const LowonganMitra({super.key});

  @override
  ConsumerState<LowonganMitra> createState() => _LowonganMitraState();
}

class _LowonganMitraState extends ConsumerState<LowonganMitra> {
  String _filterStatus = "Semua";
  final Color primaryColor = const Color(0xFF19A7CE);

  // Logic Hapus Loker
  Future<void> _deleteLoker(int id) async {
    try {
      await supabase.from('program_magang').delete().eq('id', id);
      ref.invalidate(mitraJobsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lowongan berhasil dihapus"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
      }
    }
  }

  Future<void> _toggleStatus(int id, String currentStatus) async {
    final newStatus = currentStatus.toLowerCase() == 'buka' ? 'tutup' : 'buka';

    try {
      await supabase
          .from('program_magang')
          .update({'status_magang': newStatus})
          .eq('id', id);
      ref.invalidate(mitraJobsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Status diubah jadi: ${newStatus.toUpperCase()}"),
            duration: const Duration(milliseconds: 800),
            backgroundColor: newStatus == 'buka' ? Colors.green : Colors.grey,
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

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(mitraJobsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // 1. HEADER & FILTER
          _buildHeader(),

          // 2. LIST LOKER
          Expanded(
            child: jobsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
              data: (allJobs) {
                // Filter Lokal (Client Side Filtering)
                final filteredJobs = allJobs.where((job) {
                  if (_filterStatus == "Semua") return true;
                  return (job['status_magang'] ?? '')
                          .toString()
                          .toLowerCase() ==
                      _filterStatus.toLowerCase();
                }).toList();

                if (filteredJobs.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    100,
                  ), // Bottom padding buat FAB
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    return _buildJobCard(filteredJobs[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HEADER ---
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
                    "Kelola Lowongan",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Pantau performa lowongan kamu",
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
                child: Icon(Icons.list_alt_rounded, color: primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["Semua", "Buka", "Tutup"].map((status) {
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
                      color: isSelected ? primaryColor : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.plusJakartaSans(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
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

  // --- WIDGET JOB CARD (Actionable) ---
  Widget _buildJobCard(Map<String, dynamic> job) {
    final status = job['status_magang'] ?? 'tutup';
    final isBuka = status.toLowerCase() == 'buka';

    // Ambil jumlah pelamar dari hasil count (biasanya array of object)
    // response: ..., pendaftaran: [{count: 5}]
    final pelamarList = job['pendaftaran'] as List<dynamic>?;
    final pelamarCount = (pelamarList != null && pelamarList.isNotEmpty)
        ? pelamarList[0]['count']
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        children: [
          // BAGIAN ATAS: Info Utama
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
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
                        job['judul'] ?? 'Tanpa Judul',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Dibuat: ${_formatDate(job['created_at'])}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // MENU TITIK TIGA (Edit/Hapus)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'hapus') {
                      _showDeleteConfirm(job['id']);
                    } else if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TambahProgram(jobData: job),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit', 
                      child: Text("Edit Data")
                    ),
                    const PopupMenuItem(
                      value: 'hapus', 
                      child: Text("Hapus", style: TextStyle(color: Colors.red))
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // BAGIAN BAWAH: Stats & Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // PELAMAR BADGE
                Row(
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$pelamarCount Pelamar",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),

                // SWITCH STATUS (Buka/Tutup)
                Row(
                  children: [
                    Text(
                      isBuka ? "Buka" : "Tutup",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isBuka ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: isBuka,
                      activeColor: Colors.green,
                      onChanged: (val) => _toggleStatus(job['id'], status),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(
          "Belum ada lowongan",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Text(
          "Tekan tombol + di bawah untuk buat baru",
          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey),
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
      return isoString;
    }
  }

  void _showDeleteConfirm(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Lowongan?"),
        content: const Text("Data pelamar di lowongan ini juga akan terhapus."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteLoker(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}
