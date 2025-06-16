import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friend_provider.dart';
import '../../models/user_model.dart';
import 'friend_requests_screen.dart';
import 'add_friend_screen.dart';

class FriendsScreen extends StatefulWidget {
  static const String routeName = '/friends';

  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color primaryColor = const Color(0xFFFFA4D6); // Pink pastel

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final friendProvider = Provider.of<FriendProvider>(context);
    final currentUserId = authProvider.user?.uid;

    if (currentUserId == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Friends'),
          backgroundColor: primaryColor,
        ),
        body: const Center(
          child: Text('Silakan masuk untuk melihat teman Anda.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // title: const Text('Teman'),
        backgroundColor: primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            const Tab(text: 'Teman Saya'),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Permintaan'),
                  if (friendProvider.friendRequests.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.white,
                        child: Text(
                          friendProvider.friendRequests.length.toString(),
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFriendScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          friendProvider.isLoadingFriends
              ? const Center(child: CircularProgressIndicator())
              : friendProvider.friends.isEmpty
              ? const Center(
                child: Text(
                  'Anda belum punya teman. Tambahkan beberapa!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: friendProvider.friends.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemBuilder: (context, index) {
                  final friend = friendProvider.friends[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          friend.photoUrl ??
                              'https://via.placeholder.com/150/0000FF/FFFFFF?text=UL',
                        ),
                      ),
                      title: Text(
                        friend.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        friend.email,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Icon(Icons.chevron_right, color: primaryColor),
                      onTap: () {
                        // TODO: navigasi ke halaman profil teman
                        print('Lihat profil ${friend.name}');
                      },
                    ),
                  );
                },
              ),
          const FriendRequestsScreen(),
        ],
      ),
    );
  }
}
