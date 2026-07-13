import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  AppUser? _appUser;
  bool _isLoading = true;

  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  User? get user => _firebaseUser;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _auth.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        await _loadAppUser(user.uid);
      } else {
        _appUser = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _loadAppUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _appUser = AppUser.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error loading app user: $e');
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user != null) {
        final appUser = AppUser(
          uid: user.uid,
          email: email,
          username: username,
          totalPoints: 1000,
          availablePoints: 1000,
          totalBets: 0,
          wonBets: 0,
          winRate: 0.0,
          createdAt: DateTime.now(),
          country: 'FR',
          isPremium: false,
        );

        await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
        _appUser = appUser;
        notifyListeners();
        return null;
      }
      return 'Sign up failed';
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _appUser = null;
      notifyListeners();
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  Future<void> updateUserPoints({
    required int newPoints,
    required int newAvailablePoints,
  }) async {
    if (_appUser == null || _firebaseUser == null) return;

    try {
      _appUser = _appUser!.copyWith(
        totalPoints: newPoints,
        availablePoints: newAvailablePoints,
      );

      await _firestore.collection('users').doc(_firebaseUser!.uid).update({
        'totalPoints': newPoints,
        'availablePoints': newAvailablePoints,
      });

      notifyListeners();
    } catch (e) {
      print('Error updating points: $e');
    }
  }

  Future<void> updateUserStats({
    required int totalBets,
    required int wonBets,
  }) async {
    if (_appUser == null || _firebaseUser == null) return;

    try {
      final winRate = totalBets > 0 ? (wonBets / totalBets) * 100 : 0.0;

      _appUser = _appUser!.copyWith(
        totalBets: totalBets,
        wonBets: wonBets,
        winRate: winRate,
      );

      await _firestore.collection('users').doc(_firebaseUser!.uid).update({
        'totalBets': totalBets,
        'wonBets': wonBets,
        'winRate': winRate,
      });

      notifyListeners();
    } catch (e) {
      print('Error updating stats: $e');
    }
  }
}
