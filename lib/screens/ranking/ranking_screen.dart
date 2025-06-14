import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Model ranking untuk internal widget
class _FriendRanking {
  final String userId;
  final String name;
  final String image;
  final double totalDistance;

  _FriendRanking({
    required this.userId,
    required this.name,
    required this.image,
    required this.totalDistance,
  });
}

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});
  static const String routeName = '/ranking';

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late Future<List<_FriendRanking>> _rankingFuture;

  @override
  void initState() {
    super.initState();
    _rankingFuture = _fetchRanking();
  }

  Future<List<_FriendRanking>> _fetchRanking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final userId = user.uid;

    // 1. Ambil daftar teman user dari Firestore
    final friendsRef = FirebaseFirestore.instance
        .collection('friends')
        .doc(userId)
        .collection('friends');
    final friendsSnap = await friendsRef.get();
    final friendIds = friendsSnap.docs.map((e) => e.id).toList();

    // Jika tidak ada teman, return kosong (tangani di UI)
    if (friendIds.isEmpty) return [];

    // Tambahkan user sendiri juga ke leaderboard
    friendIds.add(userId);

    List<_FriendRanking> rankings = [];
    for (final friendId in friendIds) {
      // Ambil data profil user/teman
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .get();
      final userData = userDoc.data() ?? {};

      // Ambil semua aktivitas lari (runs)
      final runsSnap = await FirebaseFirestore.instance
          .collection('activities')
          .doc(friendId)
          .collection('runs')
          .get();

      // Hitung total distance
      double totalDistance = 0.0;
      for (final run in runsSnap.docs) {
        totalDistance += (run['distance'] ?? 0.0).toDouble();
      }

      rankings.add(
        _FriendRanking(
          userId: friendId,
          name: userData['displayName'] ?? userData['email'] ?? '-',
          image: userData['photoURL'] ??
              'https://ui-avatars.com/api/?name=${userData['displayName'] ?? userData['email'] ?? 'U'}',
          totalDistance: totalDistance,
        ),
      );
    }

    // Urutkan dari yang terjauh ke terpendek
    rankings.sort((a, b) => b.totalDistance.compareTo(a.totalDistance));
    return rankings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<List<_FriendRanking>>(
          future: _rankingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            // Jika belum punya teman
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Anda belum memiliki teman.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            // Jika sudah ada teman dan data ranking
            final rankings = snapshot.data!;
            final mvp = rankings.take(3).toList();
            final rankingList = rankings.skip(3).toList();
            return SingleChildScrollView(
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
                      'assets/images/ranking-banner.png',
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
                  _RankingList(ranking: rankingList),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Section MVP (3 teratas)
class _MvpSection extends StatelessWidget {
  final List<_FriendRanking> mvp;
  const _MvpSection({required this.mvp});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        if (i >= mvp.length) return const SizedBox();
        return _CircleMvp(
          image: mvp[i].image,
          name: mvp[i].name,
          rank: i + 1,
          highlight: i == 0
              ? Colors.blue
              : (i == 1 ? Colors.orange : Colors.lightBlue),
          size: i == 0 ? 100 : 80,
          nameFontSize: i == 0 ? 20 : 18,
          totalDistance: mvp[i].totalDistance,
        );
      }),
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
  final double totalDistance;

  const _CircleMvp({
    required this.image,
    required this.name,
    required this.rank,
    required this.highlight,
    required this.size,
    required this.nameFontSize,
    required this.totalDistance,
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
        Text(
          "${totalDistance.toStringAsFixed(2)} km",
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}

// Daftar ranking (selain top 3)
class _RankingList extends StatelessWidget {
  final List<_FriendRanking> ranking;

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
                backgroundImage: NetworkImage(user.image),
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
          title: Text(user.name),
          subtitle: Text("${user.totalDistance.toStringAsFixed(2)} km"),
        );
      }),
    );
  }
}
