import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/friend_provider.dart';
import '../../models/user_model.dart';

// FriendRequestsScreen adalah halaman untuk menampilkan dan mengelola permintaan pertemanan yang diterima
class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan Consumer untuk mendengarkan perubahan pada FriendProvider
    return Consumer<FriendProvider>(
      builder: (context, friendProvider, child) {
        // Tampilkan indikator loading jika masih memuat permintaan
        if (friendProvider.isLoadingRequests) {
          return const Center(child: CircularProgressIndicator());
        }

        // Tampilkan pesan jika tidak ada permintaan pertemanan
        if (friendProvider.friendRequests.isEmpty) {
          return const Center(child: Text('Tidak ada permintaan pertemanan baru.'));
        }

        // Tampilkan daftar permintaan pertemanan
        return ListView.builder(
          itemCount: friendProvider.friendRequests.length,
          itemBuilder: (context, index) {
            final request = friendProvider.friendRequests[index]; // Dapatkan objek permintaan
            final UserModel fromUser = request['fromUser']; // Dapatkan pengguna yang mengirim permintaan
            final String requestId = request['requestId']; // Dapatkan ID permintaan

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0, // No elevation for the card as per the latest design reference
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Keep rounded corners for clarity
              child: ListTile(
                leading: CircleAvatar(
                  radius: 24, // Larger avatar as per design
                  // Use a robust placeholder for avatar if photoUrl is null or empty
                  backgroundImage: NetworkImage(fromUser.photoUrl ?? 'https://placehold.co/150x150/CCCCCC/000000?text=${fromUser.name.isNotEmpty ? fromUser.name[0].toUpperCase() : 'U'}'),
                ),
                title: Text(fromUser.name, style: const TextStyle(fontWeight: FontWeight.w500)), // Nama pengirim
                subtitle: const Text('Mengirimi Anda permintaan pertemanan.'), // Pesan permintaan
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tombol Konfirmasi untuk menerima permintaan
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Warna biru untuk konfirmasi
                        foregroundColor: Colors.white, // Text color for the button
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: const Size(80, 36), // Set minimum size for button as per design
                      ),
                      onPressed: () async {
                        await friendProvider.acceptFriendRequest(requestId, fromUser.uid);
                        // Snackbar akan muncul setelah permintaan diterima
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Permintaan pertemanan dari ${fromUser.name} diterima!')),
                        );
                      },
                      child: const Text('Konfirmasi'),
                    ),
                    const SizedBox(width: 8), // Spasi antar tombol
                    // Tombol Hapus untuk menolak permintaan
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300], // Grey background for delete as per design
                        foregroundColor: Colors.black, // Black text for delete
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: const Size(80, 36), // Set minimum size for button
                      ),
                      onPressed: () async {
                        await friendProvider.rejectFriendRequest(requestId);
                        // Snackbar akan muncul setelah permintaan ditolak
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Permintaan pertemanan dari ${fromUser.name} ditolak.')),
                        );
                      },
                      child: const Text('Hapus'), // Label text only as per design
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}