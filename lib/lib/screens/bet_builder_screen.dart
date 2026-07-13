import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../models/bet.dart';
import '../providers/auth_provider.dart';
import '../providers/bets_provider.dart';
import '../config/theme.dart';

class BetBuilderScreen extends StatefulWidget {
  final Match match;

  const BetBuilderScreen({
    Key? key,
    required this.match,
  }) : super(key: key);

  @override
  State<BetBuilderScreen> createState() => _BetBuilderScreenState();
}

class _BetBuilderScreenState extends State<BetBuilderScreen> {
  late List<BetSelection> selectedBets;
  late int stakePoints;
  late double totalOdds;
  final stakeController = TextEditingController();
  String? selectedPrediction;

  @override
  void initState() {
    super.initState();
    selectedBets = [];
    stakePoints = 10;
    totalOdds = 1.0;
  }

  void _addBet(String prediction, double odds) {
    final bet = BetSelection(
      matchId: widget.match.id,
      prediction: prediction,
      odds: odds,
    );

    setState(() {
      selectedBets.add(bet);
      totalOdds *= odds;
      selectedPrediction = prediction;
    });
  }

  void _removeBet(int index) {
    setState(() {
      totalOdds /= selectedBets[index].odds;
      selectedBets.removeAt(index);
    });
  }

  Future<void> _placeBet() async {
    if (selectedBets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one prediction')),
      );
      return;
    }

    if (stakePoints <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stake must be greater than 0')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final betsProvider = context.read<BetsProvider>();

    if (authProvider.appUser == null) return;

    if (authProvider.appUser!.availablePoints < stakePoints) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient points'),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    await betsProvider.placeBet(
      userId: authProvider.firebaseUser!.uid,
      selections: selectedBets,
      stakePoints: stakePoints,
      totalOdds: totalOdds,
    );

    final newAvailablePoints =
        authProvider.appUser!.availablePoints - stakePoints;
    await authProvider.updateUserPoints(
