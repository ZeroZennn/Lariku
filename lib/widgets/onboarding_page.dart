import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class OnboardingPage extends StatelessWidget {
  final String title, description, image;
  final bool isActive;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return isActive
        ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BounceInUp(
              duration: const Duration(milliseconds: 800),
              child: Image.asset(image, height: 250),
            ),
            const SizedBox(height: 30),
            SlideInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 300),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SlideInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ],
        )
        : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 250),
            const SizedBox(height: 30),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        );
  }
}
