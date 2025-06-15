import 'package:flutter/material.dart';
import '../widgets/onboarding_page.dart';
import 'package:animate_do/animate_do.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/images/onboard1.png',
      'title': 'Track Your Runs',
      'description': 'Pantau jarak dan waktu lari kamu secara real-time.',
    },
    {
      'image': 'assets/images/onboard2.png',
      'title': 'Save Your Progress',
      'description': 'Simpan histori aktivitas lari kamu.',
    },
    {
      'image': 'assets/images/onboard3.png',
      'title': 'Join with Friends',
      'description': 'Buat pertemanan dan bersaing di leaderboard.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return OnboardingPage(
                  title: onboardingData[index]['title']!,
                  description: onboardingData[index]['description']!,
                  image: onboardingData[index]['image']!,
                  isActive: index == currentIndex, // ⬅️ Ini kunci utamanya
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(4),
                width: currentIndex == index ? 12 : 10,
                height: currentIndex == index ? 12 : 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == index ? Colors.blue : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (currentIndex == onboardingData.length - 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigasi ke halaman login
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Get Started'),
              ),
            ),
        ],
      ),
    );
  }
}
