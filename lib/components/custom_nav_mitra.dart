import 'package:flutter/material.dart';

class CustomNavMitra extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavMitra({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final Color primaryBlue = const Color(0xFF2196F3);
  final double navHeight = 80; // Tinggi area putih navbar
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
          // 1. Background Putih dengan Lekukan
          // Kita geser gambarnya ke bawah sejauh 'floatSpace'
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

          // 2. Floating Action Button (Lingkaran Biru)
          // Sekarang top-nya bukan minus, tapi 0 (di area transparan tadi)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutQuad,
            top: 0, // Posisi paling atas dari container (area transparan)
            left: (size.width / 3) * currentIndex + (size.width / 3) / 2 - 28,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: primaryBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(_getIcon(currentIndex), color: Colors.white),
            ),
          ),

          // 3. Icon & Label (Posisi tetap di area putih)
          Positioned(
            top: floatSpace, // Turun ke bawah, pas di area putih
            left: 0,
            right: 0,
            height: navHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(context, 0, Icons.dashboard_rounded, "Dashboard"),
                _buildNavItem(context, 1, Icons.search_rounded, "Pencarian"),
                _buildNavItem(context, 2, Icons.home_rounded, "Profil"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.search_rounded;
      case 2:
        return Icons.person_rounded;
      default:
        return Icons.dashboard_rounded;
    }
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: isSelected ? 35 : 0),
            isSelected
                ? const SizedBox(height: 24)
                : Icon(icon, color: Colors.grey.shade400),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isSelected ? 1.0 : 0.0,
              child: isSelected
                  ? Text(
                      label,
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

// --- LOGIKA MENGGAMBAR (Update Offset) ---
class NavbarPainter extends CustomPainter {
  final int selectedIndex;
  final int itemsCount;
  final double topOffset; // Parameter baru buat geser gambar ke bawah

  NavbarPainter(this.selectedIndex, this.itemsCount, this.topOffset);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();

    // Mulai menggambar dari topOffset (misal pixel ke-30 dari atas)
    double startY = topOffset;

    path.moveTo(0, startY);

    double itemWidth = size.width / itemsCount;
    double centerX = (itemWidth * selectedIndex) + (itemWidth / 2);

    // Garis lurus kiri
    path.lineTo(centerX - 45, startY);

    // Curve Lekukan
    // Semua koordinat Y ditambah startY biar turun
    path.cubicTo(
      centerX - 25,
      startY,
      centerX - 25,
      startY + 45, // Kedalaman 45 pixel dari garis putih
      centerX,
      startY + 45,
    );
    path.cubicTo(
      centerX + 25,
      startY + 45,
      centerX + 25,
      startY,
      centerX + 45,
      startY,
    );

    // Garis lurus kanan
    path.lineTo(size.width, startY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.1), 4.0, true);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant NavbarPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex;
  }
}
