import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/matches_provider.dart';
import '../providers/bets_provider.dart';
import '../providers/user_provider.dart';
import '../config/theme.dart';
import 'bet_builder_screen.dart';
import 'leaderboard_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchesProvider>().fetchMatches();
      context.read<UserProvider>().loadLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BetPredix'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Chip(
                    label: Text(
                      '💰 ${authProvider.appUser?.availablePoints ?? 0}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: primaryColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildMatchesTab();
      case 1:
        return const LeaderboardScreen();
      case 2:
        return const WalletScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildMatchesTab();
    }
  }

  Widget _buildMatchesTab() {
    return Consumer<MatchesProvider>(
      builder: (context, matchesProvider, _) {
        if (matchesProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (matchesProvider.upcomingMatches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_soccer, size: 64, color: primaryColor),
                SizedBox(height: 16),
                Text(
                  'No matches available',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => matchesProvider.fetchMatches(),
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: matchesProvider.upcomingMatches.length + 1,
            itemBuilder: (context, index) {
              if (index == matchesProvider.upcomingMatches.length) {
                return SizedBox(height: 100);
              }

              final match = matchesProvider.upcomingMatches[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BetBuilderScreen(match: match),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              match.competition,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: match.isLive
                                    ? successColor.withOpacity(0.2)
                                    : primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                match.isLive ? '🔴 LIVE' : '⏰ UPCOMING',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: match.isLive ? successColor : primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    match.homeTeam,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    match.awayTeam,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (match.isFinished && match.homeScore != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${match.homeScore}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: successColor,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${match.awayScore}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: successColor,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        SizedBox(height: 12),

                        if (!match.isFinished)
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: darkBorder),
                                bottom: BorderSide(color: darkBorder),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Win',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${match.odds1.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Draw',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${match.oddsX.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Lose',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${match.odds2.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
