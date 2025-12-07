import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeBannerCarousel extends StatelessWidget {
  const HomeBannerCarousel({super.key});

  final List<String> imgList = const [
    'assets/images/img_banner1.png',
    'assets/images/img_banner2.png',
    'assets/images/img_banner3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280.0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 280.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              viewportFraction: 1.0,
              pageSnapping: false,
            ),
            items: imgList.map((imagePath) {
              return Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey.shade300),
              );
            }).toList(),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 40.0,
            ), // Padding atas ditambah
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Foto Profil
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 24, // Ukuran foto
                        backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/152?img=5",
                        ),
                        // Nanti ganti: AssetImage('assets/images/profile.jpg')
                      ),
                    ),
                    const SizedBox(width: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Welcome back,",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          "Plew!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                const Text(
                  "Siap Magang,\nSiap Kerja",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black45,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const Text(
                  "Bersama InternGate",
                  style: TextStyle(
                    color: Color(0xFFF5C219),
                    fontSize: 24.0,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black45,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 50,
                ), // Jarak bawah biar gak ketutup kertas putih
              ],
            ),
          ),
        ],
      ),
    );
  }
}
