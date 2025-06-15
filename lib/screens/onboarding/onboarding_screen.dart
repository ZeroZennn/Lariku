import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // 🔽 Data slide onboarding
  final List<Map<String, String>> _slides = [
    {
      'image': 'assets/images/onboard1.png',
      'title': 'Tracking Real-time',
      'desc':
          'Pantau jarak, kecepatan, andan rute larimu secara langsung dengan GPS akurat. Tidak perlu alat tambahan!',
    },
    {
      'image': 'assets/images/onboard2.png',
      'title': 'Lacak lari dengan GPS akurat',
      'desc':
          'Cek semua aktivitas lari kamu, lihat progres harian, mingguan, atau bulanan. Tetap termotivasi!',
    },
    {
      'image': 'assets/images/onboard3.png',
      'title': 'Yuk, Lari Sekarang!',
      'desc':
          'Buat akunmu sekarang dan mulai perjalanan lari yang menyenangkan bersama LARIKU.',
    },
  ];

  // 🔽 Fungsi untuk berpindah ke halaman berikutnya
  void _nextPage() {
    if (_currentPage == _slides.length - 1) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          // 🔽 Bagian utama PageView
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🔽 Gambar diperbesar secara responsif
                      SizedBox(
                        height: size.height * 0.35,
                        child: Image.asset(
                          slide['image']!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 🔽 Judul Slide
                      Text(
                        slide['title']!,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // 🔽 Deskripsi dengan margin kiri-kanan
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          slide['desc']!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 🔽 Tombol Next / Get Started
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue, // 🔵 Warna tombol
                shape:
                    _currentPage == _slides.length - 1
                        ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        )
                        : const CircleBorder(),
                padding:
                    _currentPage == _slides.length - 1
                        ? const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        )
                        : const EdgeInsets.all(20),
              ),
              child:
                  _currentPage == _slides.length - 1
                      ? const Text(
                        'GET STARTED',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 16,
                        ),
                      )
                      : const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
