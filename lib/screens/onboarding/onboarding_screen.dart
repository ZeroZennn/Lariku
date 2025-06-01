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

  final List<Map<String, String>> _slides = [
    {
      'image': 'assets/images/onboard1.png',
      'title': 'Track Your Runs',
      'desc': 'Monitor your distance, time, and route in real-time.',
    },
    {
      'image': 'assets/images/onboard2.png',
      'title': 'History & Stats',
      'desc': 'View past activities and analyze your performance.',
    },
    {
      'image': 'assets/images/onboard3.png',
      'title': 'Compete with Friends',
      'desc': 'See how you rank among your running buddies.',
    },
  ];

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
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(slide['image']!, height: 250),
                      const SizedBox(height: 40),
                      Text(
                        slide['title']!,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        slide['desc']!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: _nextPage,
              child: Text(
                _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
