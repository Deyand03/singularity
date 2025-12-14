import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomNavMitra extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavMitra({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(), // Lekukan untuk FAB
      notchMargin: 10.0, // Jarak lekukan lebih lega
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 15,
      shadowColor: Colors.black.withOpacity(0.15),
      height: 80,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Grup Kiri
          _buildNavItem(
            0,
            Icons.dashboard_rounded,
            Icons.dashboard_outlined,
            "Beranda",
          ),
          _buildNavItem(
            1,
            Icons.list_alt_rounded,
            Icons.list_alt_outlined,
            "Lowongan",
          ),

          // Spasi untuk FAB di tengah
          const SizedBox(width: 48),

          // Grup Kanan
          _buildNavItem(
            3,
            Icons.people_alt_rounded,
            Icons.people_alt_outlined,
            "Pelamar",
          ),
          _buildNavItem(
            4,
            Icons.business_rounded,
            Icons.business_outlined,
            "Profil",
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final bool isSelected = currentIndex == index;
    const primaryColor = Color(0xFF19A7CE);

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. ANIMATED BADGE ICON
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              // FIX: Ganti 'easeOutBack' ke 'fastOutSlowIn'
              // Kurva ini AMAN karena tidak pernah overshoot ke nilai negatif (minus)
              // tapi tetap memberikan efek akselerasi yang smooth dan 'mahal'.
              curve: Curves.fastOutSlowIn,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 20 : 0, // Melebar saat aktif
                vertical: isSelected ? 5 : 0, // Ada padding vertikal saat aktif
              ),
              decoration: BoxDecoration(
                // Background Transparan Biru (Badge Style)
                color: isSelected
                    ? primaryColor.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20), // Bentuk Pill/Kapsul
              ),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                // Icon jadi Biru saat aktif, Abu saat mati
                color: isSelected ? primaryColor : Colors.grey.shade400,
                size: 26,
              ),
            ),

            const SizedBox(height: 4),

            // 2. LABEL
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                // Teks jadi Bold & Biru saat aktif
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? primaryColor : Colors.grey.shade400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
