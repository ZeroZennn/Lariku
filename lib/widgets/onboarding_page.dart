import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String title, description, image;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
