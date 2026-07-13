import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<AppUser> _leaderboard = [];
  bool _isLoading = false;

  List<AppUser> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;

  Future<void> loadLeaderboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('totalPoints', descending: true)
          .limit(100)
          .get();

      _leaderboard = snapshot.docs
          .map((doc) => AppUser.fromMap(doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading leaderboard: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AppUser?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
    return null;
  }

  Future<void> updateUserStats(String uid, {
    required int newTotalPoints,
    required int newAvailablePoints,
    required int totalBets,
    required int wonBets,
  }) async {
    try {
      final winRate = totalBets > 0 ? (wonBets / totalBets * 100) : 0.0;
      
      await _firestore.collection('users').doc(uid).update({
        'totalPoints': newTotalPoints,
        'availablePoints': newAvailablePoints,
        'totalBets': totalBets,
        'wonBets': wonBets,
        'winRate': winRate,
      });

      notifyListeners();
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  int getUserRank(String uid) {
    try {
      final index = _leaderboard.indexWhere((u) => u.uid == uid);
      return index >= 0 ? index + 1 : 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> addBonusPoints(String uid, int points) async {
    try {
      final user = await getUserById(uid);
      if (user != null) {
        await _firestore.collection('users').doc(uid).update({
          'availablePoints': user.availablePoints + points,
          'totalPoints': user.totalPoints + points,
        });
        notifyListeners();
      }
    } catch (e) {
      print('Error adding bonus points: $e');
    }
  }
}
