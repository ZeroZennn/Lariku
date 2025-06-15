import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // Import untuk StreamSubscription
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

// FriendProvider mengelola status dan operasi terkait pertemanan
class FriendProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthProvider _authProvider;

  List<UserModel> _friends = [];
  List<Map<String, dynamic>> _friendRequests = [];
  List<UserModel> _searchResults = [];
  bool _isLoadingFriends = false;
  bool _isLoadingRequests = false;
  bool _isLoadingSearchResults = false;

  // StreamSubscriptions untuk mengelola listener Firestore
  StreamSubscription? _friendsSubscription;
  StreamSubscription? _friendRequestsSubscription;

  List<UserModel> get friends => _friends;
  List<Map<String, dynamic>> get friendRequests => _friendRequests;
  List<UserModel> get searchResults => _searchResults;
  bool get isLoadingFriends => _isLoadingFriends;
  bool get isLoadingRequests => _isLoadingRequests;
  bool get isLoadingSearchResults => _isLoadingSearchResults;

  // Konstruktor FriendProvider
  FriendProvider(this._authProvider) {
    _authProvider.addListener(_onAuthChange);
    _onAuthChange(); // Panggil sekali saat inisialisasi untuk memuat status awal
  }

  // Metode yang dipanggil saat status otentikasi berubah
  void _onAuthChange() {
    print('AuthProvider state changed. User: ${_authProvider.user?.uid}');
    if (_authProvider.user != null) {
      // Jika pengguna masuk, inisialisasi listener
      _listenToFriends(_authProvider.user!.uid);
      _listenToFriendRequests(_authProvider.user!.uid);
    } else {
      // Jika pengguna keluar, batalkan semua subscription dan kosongkan daftar
      _cancelSubscriptions();
      _friends = [];
      _friendRequests = [];
      _searchResults = [];
      if (!isDisposed) { // Tambahkan cek ini
        notifyListeners();
      }
    }
  }

  // Membatalkan semua stream subscriptions
  void _cancelSubscriptions() {
    _friendsSubscription?.cancel();
    _friendRequestsSubscription?.cancel();
    _friendsSubscription = null;
    _friendRequestsSubscription = null;
    print('All Firestore subscriptions cancelled.');
  }

  void _listenToFriends(String userId) {
    _isLoadingFriends = true;
    if (!isDisposed) { // Tambahkan cek ini
      notifyListeners();
    }

    // Batalkan subscription sebelumnya jika ada
    _friendsSubscription?.cancel();

    _friendsSubscription = _firestoreService.getFriends(userId).listen((snapshot) async {
      print('Friend snapshot received for $userId. Docs count: ${snapshot.docs.length}');
      List<UserModel> fetchedFriends = [];
      for (var doc in snapshot.docs) {
        print('Fetching friend details for ID: ${doc.id}');
        UserModel? friend = await _firestoreService.getUserById(doc.id);
        if (friend != null) {
          fetchedFriends.add(friend);
        } else {
          print('WARNING: Friend user model not found for ID: ${doc.id}. This user might be deleted or rules prevent access.');
        }
      }
      _friends = fetchedFriends;
      _isLoadingFriends = false;
      // Pastikan provider belum dibuang sebelum memanggil notifyListeners
      if (!isDisposed) {
        notifyListeners();
        print('Friends list updated. Total friends: ${_friends.length}');
      }
    }, onError: (error) {
      print('ERROR listening to friends: $error');
      _isLoadingFriends = false;
      if (!isDisposed) {
        notifyListeners();
      }
    });
  }

  void _listenToFriendRequests(String userId) {
    _isLoadingRequests = true;
    if (!isDisposed) { // Tambahkan cek ini
      notifyListeners();
    }

    print('Attempting to listen to pending friend requests for userId: $userId');
    // Batalkan subscription sebelumnya jika ada
    _friendRequestsSubscription?.cancel();

    _friendRequestsSubscription = _firestoreService.getFriendRequestsToUser(userId).listen((snapshot) async {
      print('Pending friend requests snapshot received for $userId. Docs count: ${snapshot.docs.length}');
      List<Map<String, dynamic>> fetchedRequests = [];
      for (var doc in snapshot.docs) {
        print('Processing request ID: ${doc.id}, fromUserId: ${doc['fromUserId']}');
        if (doc.data() is Map<String, dynamic> && doc['fromUserId'] != null) {
          UserModel? fromUser = await _firestoreService.getUserById(doc['fromUserId']);
          if (fromUser != null) {
            fetchedRequests.add({
              'requestId': doc.id,
              'fromUser': fromUser,
            });
            print('Added pending request from: ${fromUser.name} (ID: ${fromUser.uid})');
          } else {
            print('WARNING: Could not find UserModel for fromUserId: ${doc['fromUserId']}. Ensure user exists and Firestore rules allow access to /users/{userId}.');
          }
        } else {
          print('WARNING: Request document ${doc.id} missing fromUserId or data is not map.');
        }
      }
      _friendRequests = fetchedRequests;
      _isLoadingRequests = false;
      // Pastikan provider belum dibuang sebelum memanggil notifyListeners
      if (!isDisposed) {
        notifyListeners();
        print('Pending friend requests list updated. Total requests: ${_friendRequests.length}');
      }
    }, onError: (error) {
      print('ERROR listening to pending friend requests: $error');
      _isLoadingRequests = false;
      if (!isDisposed) {
        notifyListeners();
      }
    });
  }

  Future<void> searchUsers(String query) async {
    _isLoadingSearchResults = true;
    if (!isDisposed) { // Tambahkan cek ini
      notifyListeners();
    }
    _searchResults = [];

    try {
      String? currentUserId = _authProvider.user?.uid;
      if (currentUserId == null) {
        print('User not logged in. Cannot search for users.');
        _isLoadingSearchResults = false;
        if (!isDisposed) { // Tambahkan cek ini
          notifyListeners();
        }
        return;
      }
      print('Searching users with query: $query for user: $currentUserId');
      List<UserModel> users = await _firestoreService.searchUsers(query);
      print('Found ${users.length} users from search.');
      
      List<UserModel> filteredUsers = [];
      for (var user in users) {
        if (user.uid == currentUserId) continue;

        bool areAlreadyFriends = await _firestoreService.areFriends(currentUserId, user.uid);
        bool hasSentRequest = await _firestoreService.hasSentFriendRequest(currentUserId, user.uid); // Cek pending request
        bool hasReceivedRequest = await _firestoreService.hasReceivedFriendRequest(currentUserId, user.uid); // Cek pending request

        print('User ${user.name} (UID: ${user.uid}) - Friends: $areAlreadyFriends, Sent: $hasSentRequest, Received: $hasReceivedRequest');

        if (!areAlreadyFriends && !hasSentRequest && !hasReceivedRequest) {
          filteredUsers.add(user);
        }
      }
      _searchResults = filteredUsers;
      print('Filtered search results. Displaying ${filteredUsers.length} users.');
    } catch (e) {
      print('ERROR searching users: $e');
    } finally {
      _isLoadingSearchResults = false;
      if (!isDisposed) { // Tambahkan cek ini
        notifyListeners();
      }
    }
  }

  Future<bool> sendFriendRequest(String toUserId) async {
    String? currentUserId = _authProvider.user?.uid;
    if (currentUserId == null) {
      print('User not logged in to send friend request.');
      return false;
    }
    print('Sending friend request from $currentUserId to $toUserId');
    try {
      await _firestoreService.sendFriendRequest(currentUserId, toUserId);
      print('Friend request sent successfully.');
      // Setelah mengirim permintaan, Anda mungkin ingin memperbarui hasil pencarian
      // Panggil searchUsers lagi dengan query yang sama jika Anda ingin me-refresh UI AddFriendScreen
      // atau kosongkan searchResults jika ingin menghapus user yang baru saja dikirimi request.
      // Di sini kita tidak lagi bergantung pada _searchController, melainkan pada logika AddFriendScreen
      // untuk memanggil searchUsers() lagi atau membersihkan UI-nya.
      return true;
    } catch (e) {
      print('ERROR sending friend request: $e');
      return false;
    }
  }

  Future<bool> acceptFriendRequest(String requestId, String fromUserId) async {
    String? currentUserId = _authProvider.user?.uid;
    if (currentUserId == null) {
      print('User not logged in to accept friend request.');
      return false;
    }
    print('Accepting request ID: $requestId from $fromUserId by $currentUserId');
    try {
      await _firestoreService.acceptFriendRequest(requestId, fromUserId, currentUserId);
      print('Friend request accepted successfully.');
      return true;
    } catch (e) {
      print('ERROR accepting friend request: $e');
      return false;
    }
  }

  Future<bool> rejectFriendRequest(String requestId) async {
    print('Rejecting request ID: $requestId');
    try {
      await _firestoreService.rejectFriendRequest(requestId);
      print('Friend request rejected successfully.');
      return true;
    } catch (e) {
      print('ERROR rejecting friend request: $e');
      return false;
    }
  }

  // Flag untuk melacak apakah provider sudah dibuang
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    print('FriendProvider disposed. Cancelling all subscriptions.');
    _isDisposed = true; // Set flag to true
    _cancelSubscriptions(); // Cancel all stream subscriptions
    _authProvider.removeListener(_onAuthChange); // Remove listener from AuthProvider
    super.dispose();
  }
}
