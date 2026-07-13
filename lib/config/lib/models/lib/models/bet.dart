class BetSelection {
  final String matchId;
  final String prediction;
  final double odds;

  BetSelection({
    required this.matchId,
    required this.prediction,
    required this.odds,
  });

  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'prediction': prediction,
      'odds': odds,
    };
  }

  factory BetSelection.fromMap(Map<String, dynamic> map) {
    return BetSelection(
      matchId: map['matchId'] ?? '',
      prediction: map['prediction'] ?? '1',
      odds: (map['odds'] ?? 1.0).toDouble(),
    );
  }
}

class Bet {
  final String id;
  final String userId;
  final List<BetSelection> selections;
  final int stakePoints;
  final double totalOdds;
  final int? winningsPoints;
  final String status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final int correctPredictions;
  final int totalSelections;

  Bet({
    required this.id,
    required this.userId,
    required this.selections,
    required this.stakePoints,
    required this.totalOdds,
    this.winningsPoints,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    required this.correctPredictions,
    required this.totalSelections,
  });

  int getPotentialWinnings() {
    return (stakePoints * totalOdds).toInt();
  }

  int getProfit() {
    if (status == 'won' && winningsPoints != null) {
      return winningsPoints! - stakePoints;
    }
    if (status == 'lost') {
      return -stakePoints;
    }
    return 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'selections': selections.map((s) => s.toMap()).toList(),
      'stakePoints': stakePoints,
      'totalOdds': totalOdds,
      'winningsPoints': winningsPoints,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'correctPredictions': correctPredictions,
      'totalSelections': totalSelections,
    };
  }

  factory Bet.fromMap(Map<String, dynamic> map) {
    return Bet(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      selections: (map['selections'] as List?)
          ?.map((s) => BetSelection.fromMap(s as Map<String, dynamic>))
          .toList() ?? [],
      stakePoints: map['stakePoints'] ?? 0,
      totalOdds: (map['totalOdds'] ?? 1.0).toDouble(),
      winningsPoints: map['winningsPoints'],
      status: map['status'] ?? 'pending',
      createdAt: DateTime
