import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomNavMhs extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavMhs({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                0,
                Icons.home_rounded,
                Icons.home_outlined,
                "Beranda",
              ),
              _buildNavItem(
                1,
                Icons.work_rounded,
                Icons.work_outline,
                "Program",
              ),
              _buildNavItem(
                2,
                Icons.person_rounded,
                Icons.person_outline,
                "Profil",
              ),
            ],
          ),
        ),
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

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70, // Lebar area tap
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // STACK: Pill Background & Icon
            Stack(
              alignment: Alignment.center,
              children: [
                // 1. Pill Background (Membesar/Mengecil)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  // FIX: Gunakan curve yang AMAN (tidak membal ke nilai negatif)
                  // fastOutSlowIn memberikan efek akselerasi yang 'mahal' tanpa risiko error
                  curve: Curves.fastOutSlowIn,
                  height: 32,
                  width: isSelected ? 54 : 0, // Kalau mati lebarnya 0 (hilang)
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                // 2. Icon (Selalu ada di tengah)
                Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  color: isSelected ? primaryColor : Colors.grey.shade400,
                  size: 24,
                ),
              ],
            ),

            const SizedBox(height: 6),

            // LABEL (Selalu Muncul)
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? primaryColor : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
