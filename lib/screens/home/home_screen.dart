import 'package:flutter/material.dart';
import '../activities/activities_screen.dart';
import '../friendship/friends_screen.dart';
import '../ranking/ranking_screen.dart';
import '../run_tracker/run_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Gunakan getter agar context bisa dipakai di dalam tombol!
  List<Widget> get _pages => [
    // --- INI HALAMAN HOME BARU SESUAI DESAIN GAMBAR ---
    ListView(
      padding: EdgeInsets.zero,
      children: [
        // 1. Salam & Foto Profil
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 38,
            bottom: 14,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Halo, Arya!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D3D3D),
                ),
              ),
              // Profile pic placeholder
              CircleAvatar(
                backgroundColor: const Color(0xFFD7D7D7),
                radius: 26,
              ),
            ],
          ),
        ),

        // 2. Personal Best (atas abu, bawah peta)
        Container(
          color: const Color(0xFF686868),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 18,
                  bottom: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Personal Best",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Jarak",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "5.2 Km",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 36),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Pace",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "5:43 /Km",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Map icon section (background abu muda)
              Container(
                width: double.infinity,
                color: const Color(0xFFD7D7D7),
                padding: const EdgeInsets.symmetric(vertical: 34),
                alignment: Alignment.center,
                child: Icon(Icons.map_outlined, size: 74, color: Colors.black),
              ),
            ],
          ),
        ),

        // 3. Tombol Mulai Lari
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 24, top: 36, bottom: 28),
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _currentIndex = 2; // index 2 adalah "Run"
              });
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 13),
              backgroundColor: const Color(0xFFD7D7D7),
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Mulai Lari",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward, size: 22),
              ],
            ),
          ),
        ),

        // 4. Suggested Goal
        Container(
          color: const Color(0xFF686868),
          width: double.infinity,
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 14,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Suggested Goal",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.directions_run, size: 36, color: Colors.white),
                      const SizedBox(width: 13),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "5 Km per week",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            "2 Km / 5Km run",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFD7D7D7),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    child: const Text("Set Goal"),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    ),

    // --- END OF CUSTOM HOME PAGE ---
    const RankingScreen(),
    const RunScreen(),
    const FriendsScreen(),
    const ActivitiesScreen(),
  ];

  final List<String> _titles = [
    'Beranda',
    'Peringkat',
    'Lari',
    'Teman',
    'Aktivitas',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            label: 'Ranking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'Run',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Activities',
          ),
        ],
      ),
    );
  }
}
