import 'package:flutter/material.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});
  static const String routeName = '/ranking';

  // Contoh data dummy
  final List<Map<String, dynamic>> mvp = const [
    {
      'name': 'Yasmeen',
      'image':
          'https://i.imgur.com/J0yB6aP.png', // ganti dengan url/image asset kamu
      'rank': 1,
    },
    {'name': 'Xeyla', 'image': 'https://i.imgur.com/AG6Ml8M.png', 'rank': 2},
    {'name': 'mamat', 'image': 'https://i.imgur.com/n6zE5gD.png', 'rank': 3},
  ];

  final List<Map<String, dynamic>> ranking = const [
    {'name': 'Zikran', 'image': 'https://i.imgur.com/YJpOYyE.png'},
    {'name': 'Jema', 'image': 'https://i.imgur.com/YJpOYyE.png'},
    {'name': 'Payel', 'image': 'https://i.imgur.com/YJpOYyE.png'},
    {'name': 'Sukro', 'image': 'https://i.imgur.com/YJpOYyE.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Ranking',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/ranking-banner.png', // ganti sesuai asset kamu
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'MVP this week',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 28),
              _MvpSection(mvp: mvp),
              const SizedBox(height: 28),
              _RankingList(ranking: ranking),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _MvpSection extends StatelessWidget {
  final List<Map<String, dynamic>> mvp;

  const _MvpSection({required this.mvp});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Rank 2 (kiri)
        _CircleMvp(
          image: mvp[1]['image'],
          name: mvp[1]['name'],
          rank: mvp[1]['rank'],
          highlight: Colors.orange,
          size: 80,
          nameFontSize: 18,
        ),
        // Rank 1 (tengah)
        _CircleMvp(
          image: mvp[0]['image'],
          name: mvp[0]['name'],
          rank: mvp[0]['rank'],
          highlight: Colors.blue,
          size: 100,
          nameFontSize: 20,
        ),
        // Rank 3 (kanan)
        _CircleMvp(
          image: mvp[2]['image'],
          name: mvp[2]['name'],
          rank: mvp[2]['rank'],
          highlight: Colors.lightBlue,
          size: 80,
          nameFontSize: 18,
        ),
      ],
    );
  }
}

class _CircleMvp extends StatelessWidget {
  final String image;
  final String name;
  final int rank;
  final Color highlight;
  final double size;
  final double nameFontSize;

  const _CircleMvp({
    required this.image,
    required this.name,
    required this.rank,
    required this.highlight,
    required this.size,
    required this.nameFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: highlight.withOpacity(0.13),
              ),
              child: ClipOval(
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (ctx, _, __) => const Icon(Icons.person, size: 44),
                ),
              ),
            ),
            Positioned(
              top: -10,
              right: -10,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: highlight,
                child: Text(
                  rank.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[600],
            fontSize: nameFontSize,
          ),
        ),
      ],
    );
  }
}

class _RankingList extends StatelessWidget {
  final List<Map<String, dynamic>> ranking;

  const _RankingList({required this.ranking});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(ranking.length, (index) {
        final user = ranking[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          horizontalTitleGap: 10,
          leading: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user['image']),
                radius: 16,
              ),
              Positioned(
                left: -28,
                child: Text(
                  '${index + 4}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          title: Text(user['name']),
        );
      }),
    );
  }
}

