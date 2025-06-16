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
  List<Map<String, dynamic>> _friendRequests = []; // Permintaan diterima (status pending)
  List<Map<String, dynamic>> _sentRequests = []; // Permintaan dikirim (status pending)
  List<UserModel> _searchResults = [];

  bool _isLoadingFriends = false;
  bool _isLoadingRequests = false; // Loading untuk permintaan diterima
  bool _isLoadingSentRequests = false; // Loading untuk permintaan dikirim
  bool _isLoadingSearchResults = false;

  // StreamSubscriptions untuk mengelola listener Firestore
  StreamSubscription? _friendsSubscription;
  StreamSubscription? _friendRequestsSubscription;
  StreamSubscription? _sentRequestsSubscription;

  List<UserModel> get friends => _friends;
  List<Map<String, dynamic>> get friendRequests => _friendRequests;
  List<Map<String, dynamic>> get sentRequests => _sentRequests; // Getter untuk permintaan dikirim
  List<UserModel> get searchResults => _searchResults;

  bool get isLoadingFriends => _isLoadingFriends;
  bool get isLoadingRequests => _isLoadingRequests;
  bool get isLoadingSentRequests => _isLoadingSentRequests; // Getter untuk loading permintaan dikirim
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
      _listenToSentFriendRequests(_authProvider.user!.uid); // Inisialisasi listener untuk permintaan dikirim
    } else {
      // Jika pengguna keluar, batalkan semua subscription dan kosongkan daftar
      _cancelSubscriptions();
      _friends = [];
      _friendRequests = [];
      _sentRequests = []; // Kosongkan daftar permintaan dikirim
      _searchResults = [];
      if (!isDisposed) {
        notifyListeners();
      }
    }
  }

  // Membatalkan semua stream subscriptions
  void _cancelSubscriptions() {
    _friendsSubscription?.cancel();
    _friendRequestsSubscription?.cancel();
    _sentRequestsSubscription?.cancel(); // Batalkan subscription untuk permintaan dikirim
    _friendsSubscription = null;
    _friendRequestsSubscription = null;
    _sentRequestsSubscription = null; // Set null
    print('All Firestore subscriptions cancelled.');
  }

  void _listenToFriends(String userId) {
    _isLoadingFriends = true;
    if (!isDisposed) {
      notifyListeners();
    }

    _friendsSubscription?.cancel(); // Batalkan subscription sebelumnya jika ada

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
    if (!isDisposed) {
      notifyListeners();
    }

    print('Attempting to listen to pending received friend requests for userId: $userId');
    _friendRequestsSubscription?.cancel(); // Batalkan subscription sebelumnya jika ada

    _friendRequestsSubscription = _firestoreService.getFriendRequestsToUser(userId).listen((snapshot) async {
      print('Pending received friend requests snapshot received for $userId. Docs count: ${snapshot.docs.length}');
      List<Map<String, dynamic>> fetchedRequests = [];
      for (var doc in snapshot.docs) {
        print('Processing received request ID: ${doc.id}, fromUserId: ${doc['fromUserId']}');
        if (doc.data() is Map<String, dynamic> && doc['fromUserId'] != null) {
          UserModel? fromUser = await _firestoreService.getUserById(doc['fromUserId']);
          if (fromUser != null) {
            fetchedRequests.add({
              'requestId': doc.id,
              'fromUser': fromUser,
            });
            print('Added pending received request from: ${fromUser.name} (ID: ${fromUser.uid})');
          } else {
            print('WARNING: Could not find UserModel for fromUserId: ${doc['fromUserId']}. Ensure user exists and Firestore rules allow access to /users/{userId}.');
          }
        } else {
          print('WARNING: Received request document ${doc.id} missing fromUserId or data is not map.');
        }
      }
      _friendRequests = fetchedRequests;
      _isLoadingRequests = false;
      if (!isDisposed) {
        notifyListeners();
        print('Pending received friend requests list updated. Total requests: ${_friendRequests.length}');
      }
    }, onError: (error) {
      print('ERROR listening to pending received friend requests: $error');
      _isLoadingRequests = false;
      if (!isDisposed) {
        notifyListeners();
      }
    });
  }

  // Metode untuk mendengarkan permintaan pertemanan yang dikirim (pending)
  void _listenToSentFriendRequests(String userId) {
    _isLoadingSentRequests = true;
    if (!isDisposed) {
      notifyListeners();
    }

    print('Attempting to listen to pending sent friend requests from userId: $userId');
    _sentRequestsSubscription?.cancel(); // Batalkan subscription sebelumnya jika ada

    _sentRequestsSubscription = _firestoreService.getSentFriendRequests(userId).listen((snapshot) async {
      print('Pending sent friend requests snapshot received from $userId. Docs count: ${snapshot.docs.length}');
      List<Map<String, dynamic>> fetchedSentRequests = [];
      for (var doc in snapshot.docs) {
        print('Processing sent request ID: ${doc.id}, toUserId: ${doc['toUserId']}');
        if (doc.data() is Map<String, dynamic> && doc['toUserId'] != null) {
          UserModel? toUser = await _firestoreService.getUserById(doc['toUserId']);
          if (toUser != null) {
            fetchedSentRequests.add({
              'requestId': doc.id,
              'toUser': toUser, // Menyimpan detail penerima
            });
            print('Added pending sent request to: ${toUser.name} (ID: ${toUser.uid})');
          } else {
            print('WARNING: Could not find UserModel for toUserId: ${doc['toUserId']}. Ensure user exists and Firestore rules allow access to /users/{userId}.');
          }
        } else {
          print('WARNING: Sent request document ${doc.id} missing toUserId or data is not map.');
        }
      }
      _sentRequests = fetchedSentRequests;
      _isLoadingSentRequests = false;
      if (!isDisposed) {
        notifyListeners();
        print('Pending sent friend requests list updated. Total sent requests: ${_sentRequests.length}');
      }
    }, onError: (error) {
      print('ERROR listening to pending sent friend requests: $error');
      _isLoadingSentRequests = false;
      if (!isDisposed) {
        notifyListeners();
      }
    });
  }

  Future<void> searchUsers(String query) async {
    _isLoadingSearchResults = true;
    if (!isDisposed) {
      notifyListeners();
    }
    _searchResults = [];

    try {
      String? currentUserId = _authProvider.user?.uid;
      if (currentUserId == null) {
        print('User not logged in. Cannot search for users.');
        _isLoadingSearchResults = false;
        if (!isDisposed) {
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
      if (!isDisposed) {
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
      // Tidak perlu memanggil searchUsers('') di sini karena listener _listenToSentFriendRequests
      // akan secara otomatis memperbarui daftar sentRequests.
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

  // Metode untuk membatalkan permintaan yang telah dikirim
  Future<bool> cancelSentFriendRequest(String requestId) async {
    print('Cancelling sent request ID: $requestId');
    try {
      await _firestoreService.cancelSentFriendRequest(requestId);
      print('Sent friend request cancelled successfully.');
      return true;
    } catch (e) {
      print('ERROR cancelling sent friend request: $e');
      return false;
    }
  }

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
