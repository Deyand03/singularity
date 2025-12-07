import 'package:flutter/material.dart';
import '../components/home_banner.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Stack(
            children: [
              const HomeBannerCarousel(), // Banner Profil & Slogan

              // KERTAS PUTIH
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 240),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 20),
                    _buildMiniDashboard(),
                    const SizedBox(height: 20),

                    // 2. Kategori
                    _buildSectionHeader("Kategori Lowongan", () {}),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 20),
                        children: [
                          _buildCategoryItem("Web Developer", Icons.web_rounded, Colors.blue),
                          _buildCategoryItem("Mobile Developer", Icons.phone_android_rounded, Colors.purple),
                          _buildCategoryItem("UI/UX Designer", Icons.brush_rounded, Colors.green),
                          _buildCategoryItem("Cyber Security", Icons.computer_rounded, Colors.orange),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 3. Lowongan
                    _buildSectionHeader("Lowongan Terbaru", () {}),
                    // ... (lanjutan lowongan kamu)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          _buildJobCard(),
                          _buildJobCard(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BARU: MINI DASHBOARD ---
  Widget _buildMiniDashboard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Efek shadow halus biar kayak kartu melayang
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDashboardItem("3", "Terkirim", Icons.send_rounded, Colors.blue),
          // Garis pemisah vertikal
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildDashboardItem("1", "Interview", Icons.people_alt_rounded, Colors.orange),
          // Garis pemisah vertikal
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildDashboardItem("0", "Ditolak", Icons.close_rounded, Colors.red),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(String value, String label, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(width: 8,),
            Container(
              width: 25, height: 25,
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 15),
            ),
          ],
        ),
        Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
        child: Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        ),
      ],
    );
  }

  Widget _buildJobCard() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      height: 100,
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)
      ),
      child: const Center(child: Text("Card Lowongan")),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}