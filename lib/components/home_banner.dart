import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:singularity/providers/mahasiswa_beranda_provider.dart';

class HomeBannerCarousel extends ConsumerWidget {
  const HomeBannerCarousel({super.key});

  final List<String> imgList = const [
    'assets/images/img_banner1.png',
    'assets/images/img_banner2.png',
    'assets/images/img_banner3.png',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
            child: userProfile.when(
              data: (data) => Column(
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
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(
                            data['foto_profil'] ??
                                "https://i.pravatar.cc/152?img=5",
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome back,",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "${data['nama'].split(' ')[0]} 👋",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

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
              loading: () => const Row(
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    "Loading profile...",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              error: (error, stackTrace) => Container(
                color: Colors.redAccent.withOpacity(0.7),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Error loading profile",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
