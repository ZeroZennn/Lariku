import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/friend_provider.dart';
import '../../models/user_model.dart';

// FriendRequestsScreen adalah halaman untuk menampilkan dan mengelola permintaan pertemanan (diterima dan dikirim)
class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi TabController dengan 2 tab: Diterima dan Terkirim
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendProvider>(
      builder: (context, friendProvider, child) {
        return Column(
          children: [
            // TabBar untuk memilih antara permintaan Diterima dan Terkirim
            Container(
              color: Colors.white, // Latar belakang putih untuk TabBar
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white, // Warna teks tab yang dipilih
                unselectedLabelColor:
                    Colors.black, // Warna teks tab yang tidak dipilih
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.lightBlue.shade200, // Warna indikator tab
                ),
                tabs: [
                  // Tab untuk permintaan Diterima
                  Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.lightBlue.shade200),
                      ),
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
                                  friendProvider.friendRequests.length
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Tab untuk permintaan Terkirim
                  Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.lightBlue.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Terkirim'),
                          if (friendProvider.sentRequests.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor:
                                    Colors
                                        .orange, // Warna berbeda untuk badge terkirim
                                child: Text(
                                  friendProvider.sentRequests.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // TabBarView untuk menampilkan konten tab yang berbeda
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Konten untuk tab "Diterima"
                  _buildReceivedRequestsList(friendProvider),
                  // Konten untuk tab "Terkirim"
                  _buildSentRequestsList(friendProvider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget terpisah untuk daftar permintaan yang Diterima
  Widget _buildReceivedRequestsList(FriendProvider friendProvider) {
    if (friendProvider.isLoadingRequests) {
      return const Center(child: CircularProgressIndicator());
    }

    if (friendProvider.friendRequests.isEmpty) {
      return const Center(child: Text('Tidak ada permintaan pertemanan baru.'));
    }

    return ListView.builder(
      itemCount: friendProvider.friendRequests.length,
      itemBuilder: (context, index) {
        final request = friendProvider.friendRequests[index];
        final UserModel fromUser = request['fromUser'];
        final String requestId = request['requestId'];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                fromUser.photoUrl ??
                    'https://placehold.co/150x150/CCCCCC/000000?text=${fromUser.name.isNotEmpty ? fromUser.name[0].toUpperCase() : 'U'}',
              ),
            ),
            title: Text(
              fromUser.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Mengirimi Anda permintaan pertemanan.'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue.shade200,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: const Size(80, 36),
                  ),
                  onPressed: () async {
                    await friendProvider.acceptFriendRequest(
                      requestId,
                      fromUser.uid,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Permintaan pertemanan dari ${fromUser.name} diterima!',
                        ),
                      ),
                    );
                  },
                  child: const Text('Konfirmasi'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: const Size(80, 36),
                  ),
                  onPressed: () async {
                    await friendProvider.rejectFriendRequest(requestId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Permintaan pertemanan dari ${fromUser.name} ditolak.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Tolak'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget terpisah untuk daftar permintaan yang Terkirim
  Widget _buildSentRequestsList(FriendProvider friendProvider) {
    if (friendProvider.isLoadingSentRequests) {
      return const Center(child: CircularProgressIndicator());
    }

    if (friendProvider.sentRequests.isEmpty) {
      return const Center(
        child: Text('Tidak ada permintaan pertemanan terkirim yang tertunda.'),
      );
    }

    return ListView.builder(
      itemCount: friendProvider.sentRequests.length,
      itemBuilder: (context, index) {
        final request = friendProvider.sentRequests[index];
        final UserModel toUser =
            request['toUser']; // Dapatkan pengguna penerima
        final String requestId = request['requestId'];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                toUser.photoUrl ??
                    'https://placehold.co/150x150/0000FF/FFFFFF?text=${toUser.name.isNotEmpty ? toUser.name[0].toUpperCase() : 'U'}',
              ),
            ),
            title: Text(
              toUser.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Permintaan pertemanan terkirim.'),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.redAccent, // Warna merah untuk tombol batal
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                minimumSize: const Size(100, 36),
              ),
              onPressed: () async {
                await friendProvider.cancelSentFriendRequest(requestId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Permintaan ke ${toUser.name} dibatalkan.'),
                  ),
                );
              },
              child: const Text('Batalkan'),
            ),
          ),
        );
      },
    );
  }
}
