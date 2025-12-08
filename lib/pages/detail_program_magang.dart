import 'package:flutter/material.dart';

class DetailProgramPage extends StatelessWidget {
  final String title;
  final String companyName;
  final String address;
  final String imageUrl;
  final String quota;

  const DetailProgramPage({
    Key? key,
    required this.title,
    required this.companyName,
    required this.address,
    required this.imageUrl,
    required this.quota,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, 
      
      // 1. BODY (SCROLLABLE)
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // --- HEADER TUMPUKAN (STACK) ---
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                
                // A. BACKGROUND BIRU (DILUKIS MANUAL / CODE)
                // Kita pakai CustomPaint, BUKAN Image.asset
                SizedBox(
                  width: double.infinity,
                  height: 320, // Tinggi Header yang cukup lega
                  child: CustomPaint(
                    painter: BUMNHeaderPainter(), // <--- PELUKIS MANUAL (Lihat class di bawah)
                  ),
                ),

                // B. Tombol Back
                Positioned(
                  top: 0,
                  left: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.2),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),
                ),

                // C. Gambar Program Floating
                Container(
                  // Posisi Turun (Sesuaikan biar pas di tengah lengkungan)
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
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey[200], child: const Icon(Icons.image)),
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
                  Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87, height: 1.2)),
                  const SizedBox(height: 8),
                  Text(companyName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                  Text(address, style: TextStyle(fontSize: 13, color: Colors.grey[500])),

                  const SizedBox(height: 24),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF146C94).withOpacity(0.1)),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          _buildInfoColumn('Batas Pendaftaran', '10 Des 2025'),
                          VerticalDivider(color: Colors.grey[300], thickness: 1),
                          _buildInfoColumn('Kuota Tersedia', quota),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Buka', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),

                  const SizedBox(height: 24),
                  const Text('Deskripsi Program', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),
                  const Text('Kualifikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildBulletPoint('Wajib menguasai Flutter'),
                  _buildBulletPoint('Paham konsep Widget Tree'),
                  
                  const SizedBox(height: 40), 
                ],
              ),
            ),

            // --- KARTU LAMAR (Di dalam Scroll) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF146C94), // Biru Utama
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lamar Posisi Ini', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Batas Pendaftaran: 10 Desember 2025', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Apa yang terjadi jika tombol lamar sekarang di
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5C219),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Lamar Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

      // 2. NAVBAR (MENU BAWAH)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        currentIndex: 1, 
        selectedItemColor: const Color(0xFF146C94),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Lowongan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
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
          const Padding(padding: EdgeInsets.only(top: 6.0), child: Icon(Icons.circle, size: 6, color: Colors.black54)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[800]))),
        ],
      ),
    );
  }
}

// =======================================================
// 🎨 INI KODE PELUKISNYA (ANTI GEPENG, ADA DEKORASI)
// =======================================================
class BUMNHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBlue = Paint()..color = const Color(0xFF146C94);
    final path = Path();

    // 1. Gambar Kotak tapi sisakan ruang BANYAK di bawah (100px)
    path.lineTo(0, size.height - 100); 
    
    // 2. LENGKUNGAN MANGKOK (CONCAVE)
    // Rahasianya disini: Titik kontrol (tengah) ditarik ke BAWAH (size.height + 50)
    // Semakin besar angka +, semakin dalam lengkungannya.
    path.quadraticBezierTo(
      size.width / 2, size.height + 50, // <-- Titik tengah ditarik ke bawah banget
      size.width, size.height - 100     // <-- Titik kanan
    );
    
    path.lineTo(size.width, 0); // Naik ke atas kanan
    path.close();
    canvas.drawPath(path, paintBlue);

    // --- DEKORASI (Agar mirip desain BUMN) ---
    final paintDecor = Paint()..color = Colors.white.withOpacity(0.08); // Sedikit lebih terang (8%)

    // Lingkaran Besar Transparan (Kanan Bawah)
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.6), 100, paintDecor);
    
    // Cincin Lingkaran (Stroke)
    final paintStroke = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.75), 110, paintStroke);

    // Kotak Miring (Kiri Atas)
    canvas.save();
    canvas.translate(60, 70);
    canvas.rotate(0.3); // Miringkan
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 60, 60), const Radius.circular(12)), 
      paintDecor
    );
    canvas.restore();
    
    // Bulatan Kecil
    canvas.drawCircle(const Offset(80, 160), 15, paintDecor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}