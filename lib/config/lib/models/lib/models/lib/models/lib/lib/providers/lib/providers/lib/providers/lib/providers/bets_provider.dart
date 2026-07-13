import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/bet.dart';
import '../models/match.dart';

class BetsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Bet> _userBets = [];
  List<Bet> _pendingBets = [];
  bool _isLoading = false;

  List<Bet> get userBets => _userBets;
  List<Bet> get pendingBets => _pendingBets;
  bool get isLoading => _isLoading;

  Future<void> placeBet({
    required String userId,
    required List<BetSelection> selections,
    required int stakePoints,
    required double totalOdds,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final betId = const Uuid().v4();
      final bet = Bet(
        id: betId,
        userId: userId,
        selections: selections,
        stakePoints: stakePoints,
        totalOdds: totalOdds,
        status: 'pending',
        createdAt: DateTime.now(),
        correctPredictions: 0,
        totalSelections: selections.length,
      );

      await _firestore.collection('bets').doc(betId).set(bet.toMap());

      _userBets.add(bet);
      _pendingBets.add(bet);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error placing bet: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserBets(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('bets')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _userBets = snapshot.docs
          .map((doc) => Bet.fromMap(doc.data()))
          .toList();

      _pendingBets = _userBets.where((b) => b.status == 'pending').toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading bets: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resolveBet({
    required String betId,
    required List<Match> matches,
    required int winningsPoints,
  }) async {
    try {
      final bet = _userBets.firstWhere((b) => b.id == betId);
      
      int correctCount = 0;
      for (var selection in bet.selections) {
        final match = matches.firstWhere((m) => m.id == selection.matchId);
        
        if (match.isFinished) {
          bool isCorrect = false;
          
          if (selection.prediction == '1' && match.getResult() == '1') isCorrect = true;
          if (selection.prediction == 'X' && match.getResult() == 'X') isCorrect = true;
          if (selection.prediction == '2' && match.getResult() == '2') isCorrect = true;
          if (selection.prediction == 'O2.5' && match.homeScore! + match.awayScore! > 2) isCorrect = true;
          if (selection.prediction == 'U2.5' && match.homeScore! + match.awayScore! < 3) isCorrect = true;
          
          if (isCorrect) correctCount++;
        }
      }

      final isWon = correctCount == bet.totalSelections;
      final status = isWon ? 'won' : 'lost';

      await _firestore.collection('bets').doc(betId).update({
        'status': status,
        'correctPredictions': correctCount,
        'winningsPoints': isWon ? winningsPoints : 0,
        'resolvedAt': DateTime.now().toIso8601String(),
      });

      final betIndex = _userBets.indexWhere((b) => b.id == betId);
      if (betIndex != -1) {
        final updatedBet = Bet(
          id: bet.id,
          userId: bet.userId,
          selections: bet.selections,
          stakePoints: bet.stakePoints,
          totalOdds: bet.totalOdds,
          winningsPoints: isWon ? winningsPoints : 0,
          status: status,
          createdAt: bet.createdAt,
          resolvedAt: DateTime.now(),
          correctPredictions: correctCount,
          totalSelections: bet.totalSelections,
        );
        _userBets[betIndex] = updatedBet;
        _pendingBets.removeWhere((b) => b.id == betId);
        notifyListeners();
      }
    } catch (e) {
      print('Error resolving bet: $e');
    }
  }

  int calculateBetWinnings(int stake, double odds) {
    return (stake * odds).toInt();
  }

  int getTotalWinnings() {
    return _userBets
        .where((b) => b.status == 'won')
        .fold(0, (sum, bet) => sum + (bet.winningsPoints ?? 0));
  }

  int getTotalLosses() {
    return _userBets
        .where((b) => b.status == 'lost')
        .fold(0, (sum, bet) => sum + bet.stakePoints);
  }

  double getWinPercentage() {
    if (_userBets.isEmpty) return 0;
    final wonBets = _userBets.where((b) => b.status == 'won').length;
    return (wonBets / _userBets.length) * 100;
  }
}
