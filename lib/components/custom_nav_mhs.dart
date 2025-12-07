import 'package:flutter/material.dart';

class CustomNavMhs extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavMhs({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // Warna Utama (Biru Defry)
  final Color primaryBlue = Colors.black87;
  final double navHeight = 80;
  final double floatSpace = 30;

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double totalHeight = navHeight + floatSpace + bottomPadding;
    final Size size = MediaQuery.of(context).size;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: [
          // 1. Background Putih dengan Lekukan + Outline
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(
              size: Size(size.width, totalHeight),
              painter: NavbarPainter(currentIndex, 3, floatSpace),
            ),
          ),

          // 2. Floating Action Button (Lingkaran PUTIH POLOS)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutQuad,
            top: 0,
            left: (size.width / 3) * currentIndex + (size.width / 3) / 2 - 28,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white, // <--- GANTI JADI PUTIH
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15), // Shadow lebih soft
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              // Icon di dalam lingkaran jadi BIRU biar kontras
              child: Icon(
                _getIcon(currentIndex),
                color: primaryBlue,
                size: 28,
              ),
            ),
          ),

          // 3. Icon & Label
          Positioned(
            top: floatSpace,
            left: 0,
            right: 0,
            height: navHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(context, 0, Icons.home_outlined, "Beranda"),
                _buildNavItem(context, 1, Icons.search_outlined, "Pencarian"),
                _buildNavItem(context, 2, Icons.person_outlined, "Profil"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0: return Icons.home_rounded;
      case 1: return Icons.search_rounded;
      case 2: return Icons.person_rounded;
      default: return Icons.home_rounded;
    }
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spacer buat ngedorong label ke bawah kalau aktif
            SizedBox(height: isSelected ? 25 : 0),

            // Icon
            isSelected
                ? const SizedBox(height: 24) // Placeholder saat icon naik
                : Icon(
                icon,
                // Icon mati warnanya abu, Icon aktif ga perlu dirender disini (udah di atas)
                color: Colors.grey.shade400
            ),

            // Label (Sekarang selalu muncul, beda opacity aja)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              // Kalau aktif 1.0 (jelas), kalau gak aktif 0.6 (agak pudar)
              opacity: isSelected ? 1.0 : 0.6,
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  label,
                  style: TextStyle(
                    // Kalau aktif Biru, kalau gak aktif Abu tua
                    color: isSelected ? primaryBlue : Colors.grey.shade600,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PAINTER (Sekarang ada Outline-nya) ---
class NavbarPainter extends CustomPainter {
  final int selectedIndex;
  final int itemsCount;
  final double topOffset;

  NavbarPainter(this.selectedIndex, this.itemsCount, this.topOffset);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Cat untuk Isian Putih
    Paint fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 2. Cat untuk Garis Pinggir (Outline)
    Paint borderPaint = Paint()
      ..color = Colors.grey.shade300 // Warna outline abu tipis
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0; // Ketebalan garis

    Path path = Path();
    double startY = topOffset;

    // -- LOGIKA MEMBUAT JALUR (PATH) --
    // Kita simpan logika pathnya biar bisa dipakai 2 kali (buat isi & buat garis)

    path.moveTo(0, startY);

    double itemWidth = size.width / itemsCount;
    double centerX = (itemWidth * selectedIndex) + (itemWidth / 2);

    // Garis lurus kiri
    path.lineTo(centerX - 45, startY);

    // Curve Lekukan
    path.cubicTo(
      centerX - 25, startY,
      centerX - 25, startY + 45,
      centerX, startY + 45,
    );
    path.cubicTo(
      centerX + 25, startY + 45,
      centerX + 25, startY,
      centerX + 45, startY,
    );

    // Garis lurus kanan
    path.lineTo(size.width, startY);

    // -- MENGGAMBAR --

    // A. Gambar Shadow dulu (biar di paling belakang)
    canvas.drawShadow(path, Colors.black.withOpacity(0.05), 4.0, true);

    // B. Gambar Isian Putih (Tutup path ke bawah dulu)
    Path fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // C. Gambar Outline (Hanya di bagian atas dan lekukan)
    // Kita pakai path asli yang belum ditutup ke bawah, jadi garisnya cuma di atas
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant NavbarPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex;
  }
}