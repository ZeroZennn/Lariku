import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/friend_provider.dart';
import '../../models/user_model.dart';

class AddFriendScreen extends StatefulWidget {
  static const String routeName = '/add_friend';

  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Color primaryColor = const Color(0xFFFFA4D6); // Warna pink pastel

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendProvider>(
      builder: (context, friendProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Tambah Teman'),
            elevation: 0,
            backgroundColor: Colors.white,
            titleTextStyle: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari teman berdasarkan nama atau email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 20.0,
                    ),
                  ),
                  onChanged: (query) {
                    if (query.length > 2) {
                      friendProvider.searchUsers(query);
                    } else if (query.isEmpty) {
                      friendProvider.searchResults.clear();
                      friendProvider.searchUsers('');
                    }
                  },
                  onSubmitted: (query) {
                    if (query.isNotEmpty) {
                      friendProvider.searchUsers(query);
                    }
                  },
                ),
              ),
              Expanded(
                child:
                    friendProvider.isLoadingSearchResults
                        ? const Center(child: CircularProgressIndicator())
                        : friendProvider.searchResults.isEmpty &&
                            _searchController.text.isNotEmpty
                        ? const Center(child: Text('Pengguna tidak ditemukan.'))
                        : friendProvider.searchResults.isEmpty
                        ? const Center(
                          child: Text('Mulai ketik untuk mencari teman.'),
                        )
                        : ListView.builder(
                          itemCount: friendProvider.searchResults.length,
                          itemBuilder: (context, index) {
                            final user = friendProvider.searchResults[index];
                            final fallbackImage =
                                'https://placehold.co/150x150/F0F0F0/000000?text=${user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U'}';

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage(
                                    user.photoUrl ?? fallbackImage,
                                  ),
                                ),
                                title: Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  user.email,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  onPressed: () async {
                                    bool success = await friendProvider
                                        .sendFriendRequest(user.uid);
                                    if (success) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Permintaan dikirim ke ${user.name}!',
                                          ),
                                        ),
                                      );
                                      _searchController.clear();
                                      friendProvider.searchUsers('');
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Gagal mengirim permintaan.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'Tambah',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}
