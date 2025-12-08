import 'package:flutter/material.dart';

void main() {
  // Titik masuk utama aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profil Mahasiswa',
      home: ProfileMahasiswa(),
    );
  }
}

class ProfileMahasiswa extends StatefulWidget {
  const ProfileMahasiswa({super.key});

  @override
  State<ProfileMahasiswa> createState() => _ProfileMahasiswaState();
}

class _ProfileMahasiswaState extends State<ProfileMahasiswa> {
  final Color primaryBlue = const Color(0xFF2A73B7);
  final Color lightGrey = const Color(0xFFF7F7F7);
  final Color borderGrey = const Color(0xFFE0E0E0);
  final Color greenBadge = const Color(0xFF4CAF50);
  final Color lightGreenBadge = const Color(0xFFE5FBE4);

  Widget _buildInputField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        height: 40,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: lightGrey,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: borderGrey),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
        ),
      ),
    );
  }

  // Helper Widget untuk membuat Cell Tabel Riwayat
  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    double height = 40.0,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(8.0),
      // Alignment diatur sesuai header atau konten
      alignment: isHeader ? Alignment.center : Alignment.topLeft,
      child: Text(
        text,
        textAlign: isHeader ? TextAlign.center : TextAlign.left,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
          color: isHeader ? Colors.black87 : Colors.black54,
        ),
      ),
    );
  }

  // --- START: Widget Build Utama ---
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Header Biru (meluas ke atas)
        _buildCustomHeader(),
        // 2. Konten Utama (Card Putih, tumpang tindih)
        Positioned.fill(
          top: 130, // Jarak dari atas agar card tumpang tindih dengan header
          child: SingleChildScrollView(
            // Padding bottom penting agar konten tidak tertutup Bottom Nav Bar
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 80.0),
            child: _buildProfileCard(),
          ),
        ),
      ],
    );
  }
  // --- END: Widget Build Utama ---

  // --- DETAIL WIDGETS ---

  Widget _buildCustomHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(color: primaryBlue),
      padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil mahasiswa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Basenglah',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Ini adalah pusat kendali anda, pastikan biodata diisi dengan benar',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Ringkasan Profil ---
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'B',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basenglah',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'BASENGLAH/00000000/00000000',
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: lightGreenBadge,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Selalu Lengkap',
                    style: TextStyle(
                      color: greenBadge,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // --- Detail Biodata Section ---
            const Text(
              'Detail biodata',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 15),
            _buildInputField('NIM'),
            _buildInputField('Tempat, tanggal lahir'),
            _buildInputField('Provinsi domisili'),
            _buildInputField('Kecamatan domisili'),
            _buildInputField('Alamat domisili'),
            _buildInputField('Jenis kelamin'),
            _buildInputField('Nomor telepon'),
            _buildInputField('Kabupaten/Kota domisili'),
            _buildInputField('Kelurahan domisili'),
            const SizedBox(height: 20),

            // --- Riwayat Lamaran Magang Section ---
            const Text(
              'Riwayat Lamaran Magang',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 15),
            Table(
              border: TableBorder.all(color: borderGrey, width: 1.0),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(3),
                3: FlexColumnWidth(2),
              },
              children: [
                // Header Tabel
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF0F0F0)),
                  children: [
                    _buildTableCell('Program magang', isHeader: true),
                    _buildTableCell('Mitra', isHeader: true),
                    _buildTableCell('Tanggal Melamar', isHeader: true),
                    _buildTableCell('Status', isHeader: true),
                  ],
                ),
                // Baris Data Kosong (sesuai gambar)
                TableRow(
                  children: [
                    _buildTableCell('', height: 100),
                    _buildTableCell('', height: 100),
                    _buildTableCell('', height: 100),
                    _buildTableCell('', height: 100),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
