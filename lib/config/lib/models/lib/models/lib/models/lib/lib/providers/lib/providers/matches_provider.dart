import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match.dart';

class MatchesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Match> _upcomingMatches = [];
  bool _isLoading = false;

  List<Match> get upcomingMatches => _upcomingMatches;
  bool get isLoading => _isLoading;

  Future<void> fetchMatches() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('matches')
          .where('matchDate', isGreaterThan: DateTime.now())
          .orderBy('matchDate')
          .limit(50)
          .get();

      _upcomingMatches = snapshot.docs
          .map((doc) => Match.fromMap(doc.data()))
          .toList();

      if (_upcomingMatches.isEmpty) {
        _createMockMatches();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading matches: $e');
      _createMockMatches();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _createMockMatches() {
    final now = DateTime.now();
    final mockMatches = [
      Match(
        id: '1',
        homeTeam: 'Paris Saint-Germain',
        awayTeam: 'Marseille',
        matchDate: now.add(Duration(hours: 2)),
        status: 'upcoming',
        competition: 'Ligue 1',
        odds1: 1.65,
        oddsX: 3.80,
        odds2: 2.20,
        oddsOver25: 1.85,
        oddsUnder25: 1.95,
      ),
      Match(
        id: '2',
        homeTeam: 'Manchester City',
        awayTeam: 'Liverpool',
        matchDate: now.add(Duration(hours: 4)),
        status: 'upcoming',
        competition: 'Premier League',
        odds1: 1.75,
        oddsX: 3.60,
        odds2: 2.10,
        oddsOver25: 1.80,
        oddsUnder25: 2.00,
      ),
      Match(
        id: '3',
        homeTeam: 'Real Madrid',
        awayTeam: 'Barcelona',
        matchDate: now.add(Duration(hours: 6)),
        status: 'upcoming',
        competition: 'La Liga',
        odds1: 1.90,
        oddsX: 3.40,
        odds2: 1.95,
        oddsOver25: 1.88,
        oddsUnder25: 1.92,
      ),
      Match(
        id: '4',
        homeTeam: 'Bayern Munich',
        awayTeam: 'Borussia Dortmund',
        matchDate: now.add(Duration(hours: 8)),
        status: 'upcoming',
        competition: 'Bundesliga',
        odds1: 1.55,
        oddsX: 3.90,
        odds2: 2.40,
        oddsOver25: 1.90,
        oddsUnder25: 1.90,
      ),
      Match(
        id: '5',
        homeTeam: 'Juventus',
        awayTeam: 'AS Roma',
        matchDate: now.add(Duration(hours: 10)),
        status: 'upcoming',
        competition: 'Serie A',
        odds1: 1.72,
        oddsX: 3.70,
        odds2: 2.15,
        oddsOver25: 1.83,
        oddsUnder25: 1.97,
      ),
    ];

    _upcomingMatches = mockMatches;
  }

  Future<void> updateMatchScore(String matchId, int homeScore, int awayScore) async {
    try {
      await _firestore.collection('matches').doc(matchId).update({
        'homeScore': homeScore,
        'awayScore': awayScore,
        'status': 'finished',
      });

      final index = _upcomingMatches.indexWhere((m) => m.id == matchId);
      if (index != -1)
