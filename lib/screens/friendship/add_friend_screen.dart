// lib/screens/friendship/add_friend_screen.dart
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
  final TextEditingController _searchController = TextEditingController(); // Pastikan controller di sini

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
          appBar: AppBar(
            title: const Text('Add User'),
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
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController, // Menggunakan controller lokal
                  decoration: InputDecoration(
                    hintText: 'Search friends by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  ),
                  onChanged: (query) {
                    if (query.length > 2) {
                      friendProvider.searchUsers(query);
                    } else if (query.isEmpty) {
                      friendProvider.searchResults.clear();
                      friendProvider.searchUsers(''); // Clear search results if query is empty
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
                child: friendProvider.isLoadingSearchResults
                    ? const Center(child: CircularProgressIndicator())
                    : friendProvider.searchResults.isEmpty && _searchController.text.isNotEmpty
                        ? const Center(child: Text('No users found.'))
                        : friendProvider.searchResults.isEmpty && _searchController.text.isEmpty
                            ? const Center(child: Text('Start typing to search for users.'))
                            : ListView.builder(
                                itemCount: friendProvider.searchResults.length,
                                itemBuilder: (context, index) {
                                  final user = friendProvider.searchResults[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        radius: 24,
                                        backgroundImage: NetworkImage(user.photoUrl ?? 'https://placehold.co/150x150/F0F0F0/000000?text=${user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U'}'),
                                      ),
                                      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                      subtitle: Text(user.email),
                                      trailing: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          minimumSize: const Size(100, 36),
                                        ),
                                        onPressed: () async {
                                          bool success = await friendProvider.sendFriendRequest(user.uid);
                                          if (success) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Friend request sent to ${user.name}!')),
                                            );
                                            // Clear search text and results after success
                                            _searchController.clear(); // Bersihkan controller
                                            friendProvider.searchUsers(''); // Kosongkan hasil pencarian
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Failed to send friend request.')),
                                            );
                                          }
                                        },
                                        child: const Text('Add Friend', style: TextStyle(color: Colors.white)),
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