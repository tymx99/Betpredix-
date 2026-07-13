import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../config/theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<UserProvider, AuthProvider>(
        builder: (context, userProvider, authProvider, _) {
          if (userProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (userProvider.leaderboard.isEmpty) {
            return Center(
              child: Text('No users yet'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => userProvider.loadLeaderboard(),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: userProvider.leaderboard.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final currentUserRank = userProvider.getUserRank(
                    authProvider.firebaseUser?.uid ?? '',
                  );

                  return Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Card(
                      color: primaryColor.withOpacity(0.2),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Your Rank',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '#$currentUserRank',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        authProvider.appUser?.username ??
                                            'User',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${authProvider.appUser?.totalPoints ?? 0} points',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: successColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final user = userProvider.leaderboard[index - 1];
                final rank = index;
                final isCurrentUser = user.uid ==
                    authProvider.firebaseUser?.uid;

                String getMedalEmoji() {
                  switch (rank) {
                    case 1:
                      return '🥇';
                    case 2:
                      return '🥈';
                    case 3:
                      return '🥉';
                    default:
                      return '';
                  }
                }

                return Card(
                  color: isCurrentUser ? darkCard : null,
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              rank <= 3 ? getMedalEmoji() : '#$rank',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.username,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                user.getRank(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${user.totalPoints}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${user.winRate.toStringAsFixed(1)}% win',
                              style: TextStyle(
                                fontSize: 12,
                                color: user.winRate > 50
                                    ? successColor
                                    : errorColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
