import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/bets_provider.dart';
import '../config/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<AuthProvider, BetsProvider>(
        builder: (context, authProvider, betsProvider, _) {
          final user = authProvider.appUser;
          if (user == null) {
            return Center(
              child: Text('Not logged in'),
            );
          }

          final totalProfit = betsProvider.getTotalWinnings() -
              betsProvider.getTotalLosses();
          final roi = user.getROI();

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, Color(0xFF8B5CF6)],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              user.username.isNotEmpty
                                  ? user.username[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        Text(
                          user.username,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),

                        Text(
                          user.getRank(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildStatCard(
                            title: 'Total Points',
                            value: user.totalPoints.toString(),
                            icon: '⭐',
                            color: primaryColor,
                          ),
                          _buildStatCard(
                            title: 'Win Rate',
                            value: '${user.winRate.toStringAsFixed(1)}%',
                            icon: '📊',
                            color: user.winRate > 50 ? successColor : errorColor,
                          ),
                          _buildStatCard(
                            title: 'Total Bets',
                            value: user.totalBets.toString(),
                            icon: '🎯',
                            color: accentColor,
                          ),
                          _buildStatCard(
                            title: 'Won Bets',
                            value: user.wonBets.toString(),
                            icon: '✅',
                            color: successColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 32),

                      Text(
                        'Performance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),

                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total Profit'),
                                  Text(
                                    '${totalProfit >= 0 ? '+' : ''}$totalProfit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: totalProfit >= 0
                                          ? successColor
                                          : errorColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Divider(height: 1),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('ROI (Return on Investment)'),
                                  Text(
                                    '${roi.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          roi >= 0 ? successColor : errorColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32),

                      Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),

                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: Text('Email'),
                              subtitle: Text(user.email),
                            ),
                            Divider(height: 0),
                            ListTile(
                              title: Text('Country'),
                              subtitle: Text(user.country),
                            ),
                            Divider(height: 0),
                            ListTile(
                              title: Text('Member Since'),
                              subtitle: Text(
                                '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                              ),
                            ),
                            if (user.isPremium) ...[
                              Divider(height: 0),
                              ListTile(
                                title: Text('Premium Member'),
                                trailing: Icon(Icons.verified, color: primaryColor),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await authProvider.logout();
                          },
                          icon: Icon(Icons.logout),
                          label: Text('Logout'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: errorColor,
                            side: BorderSide(color: errorColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: TextStyle(fontSize: 32),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
