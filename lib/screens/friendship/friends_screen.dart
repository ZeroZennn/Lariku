import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friend_provider.dart';
import '../../models/user_model.dart';
import 'friend_requests_screen.dart'; // Import FriendRequestsScreen
import 'add_friend_screen.dart'; // Import AddFriendScreen

// FriendsScreen adalah halaman utama untuk menampilkan daftar teman
class FriendsScreen extends StatefulWidget {
  static const String routeName = '/friends'; // Nama rute untuk navigasi

  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController; // Controller untuk TabBar

  @override
  void initState() {
    super.initState();
    // Inisialisasi TabController dengan 2 tab
    _tabController = TabController(length: 2, vsync: this);

    // FriendProvider sudah memiliki listener untuk AuthProvider, jadi data akan dimuat secara otomatis
  }

  @override
  void dispose() {
    _tabController.dispose(); // Buang TabController saat widget dibuang
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); // Ambil AuthProvider
    final friendProvider = Provider.of<FriendProvider>(context); // Ambil FriendProvider
    final currentUserId = authProvider.user?.uid; // Dapatkan ID pengguna saat ini

    // Jika pengguna tidak login, tampilkan pesan
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Friends')),
        body: const Center(child: Text('Silakan masuk untuk melihat teman Anda.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Teman Saya'), // Tab untuk daftar teman
            // Tab untuk permintaan pertemanan dengan jumlah yang belum diterima
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Diterima'),
                  if (friendProvider.friendRequests.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          friendProvider.friendRequests.length.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Tombol untuk menambahkan teman, navigasi ke AddFriendScreen
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddFriendScreen()),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab "Teman Saya"
          friendProvider.isLoadingFriends
              ? const Center(child: CircularProgressIndicator()) // Tampilkan indikator loading jika masih memuat
              : friendProvider.friends.isEmpty
                  ? const Center(child: Text('Anda belum punya teman. Tambahkan beberapa!')) // Pesan jika tidak ada teman
                  : ListView.builder(
                      itemCount: friendProvider.friends.length,
                      itemBuilder: (context, index) {
                        final friend = friendProvider.friends[index]; // Dapatkan objek teman
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(friend.photoUrl ?? 'https://via.placeholder.com/150/0000FF/FFFFFF?text=UL'), // Tampilkan foto profil atau placeholder
                            ),
                            title: Text(friend.name), // Tampilkan nama teman
                            subtitle: Text(friend.email), // Tampilkan email teman
                            onTap: () {
                              // TODO: Navigasi ke halaman profil teman
                              print('Lihat profil ${friend.name}');
                            },
                          ),
                        );
                      },
                    ),
          // Tab "Permintaan Diterima"
          const FriendRequestsScreen(), // Tampilkan FriendRequestsScreen di tab kedua
        ],
      ),
    );
  }
}
