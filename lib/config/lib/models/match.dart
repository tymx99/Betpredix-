class Match {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final DateTime matchDate;
  final String status;
  final int? homeScore;
  final int? awayScore;
  final String competition;
  final String? homeTeamLogo;
  final String? awayTeamLogo;

  final double odds1;
  final double oddsX;
  final double odds2;
  final double oddsOver25;
  final double oddsUnder25;

  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchDate,
    required this.status,
    this.homeScore,
    this.awayScore,
    required this.competition,
    this.homeTeamLogo,
    this.awayTeamLogo,
    required this.odds1,
    required this.oddsX,
    required this.odds2,
    required this.oddsOver25,
    required this.oddsUnder25,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'matchDate': matchDate.toIso8601String(),
      'status': status,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'competition': competition,
      'homeTeamLogo': homeTeamLogo,
      'awayTeamLogo': awayTeamLogo,
      'odds1': odds1,
      'oddsX': oddsX,
      'odds2': odds2,
      'oddsOver25': oddsOver25,
      'oddsUnder25': oddsUnder25,
    };
  }

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      id: map['id'] ?? '',
      homeTeam: map['homeTeam'] ?? '',
      awayTeam: map['awayTeam'] ?? '',
      matchDate: DateTime.parse(map['matchDate'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? 'upcoming',
      homeScore: map['homeScore'],
      awayScore: map['awayScore'],
      competition: map['competition'] ?? '',
      homeTeamLogo: map['homeTeamLogo'],
      awayTeamLogo: map['awayTeamLogo'],
      odds1: (map['odds1'] ?? 1.5).toDouble(),
      oddsX: (map['oddsX'] ?? 3.0).toDouble(),
      odds2: (map['odds2'] ?? 1.5).toDouble(),
      oddsOver25: (map['oddsOver25'] ?? 1.85).toDouble(),
      oddsUnder25: (map['oddsUnder25'] ?? 1.95).toDouble(),
    );
  }

  bool get isFinished => status == 'finished';
  bool get isLive => status == 'live';
  bool get isUpcoming => status == 'upcoming';

  String getResult() {
    if (!isFinished) return 'Not finished';
    if (homeScore! > awayScore!) return '1';
    if (homeScore! < awayScore!) return '2';
    return 'X';
  }
}
