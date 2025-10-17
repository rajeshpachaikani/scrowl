import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserService>(
      builder: (context, userService, child) {
        final user = userService.currentUser;

        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final rankTitle = userService.getRankTitle(user.rewardPoints);
        final nextRank = _getNextRank(user.rewardPoints);
        final progress = _calculateProgress(user.rewardPoints);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        user.username[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.username,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        rankTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reward Points',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            '${user.rewardPoints}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      if (nextRank != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Progress to $nextRank',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).toInt()}% complete',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Statistics',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Liked',
                      user.likedTriviaIds.length.toString(),
                      Icons.favorite,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Saved',
                      user.savedTriviaIds.length.toString(),
                      Icons.bookmark,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Your Interests',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.interests.map((interest) {
                  return Chip(
                    label: Text(
                      interest.toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Text(
                'Rewards System',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              _buildRewardInfo(
                context,
                'Like a trivia',
                '${AppConstants.pointsPerLike} point',
                Icons.favorite_border,
              ),
              _buildRewardInfo(
                context,
                'Save a trivia',
                '${AppConstants.pointsPerSave} points',
                Icons.bookmark_border,
              ),
              _buildRewardInfo(
                context,
                'Submit a trivia',
                '${AppConstants.pointsPerSubmit} points',
                Icons.add_circle_outline,
              ),
              _buildRewardInfo(
                context,
                'Daily login',
                '${AppConstants.pointsPerDailyLogin} points',
                Icons.calendar_today,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardInfo(
    BuildContext context,
    String action,
    String points,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              action,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            points,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String? _getNextRank(int currentPoints) {
    for (final entry in AppConstants.rankThresholds.entries) {
      if (currentPoints < entry.value) {
        return entry.key;
      }
    }
    return null;
  }

  double _calculateProgress(int currentPoints) {
    final nextRank = _getNextRank(currentPoints);
    if (nextRank == null) return 1.0;

    final nextThreshold = AppConstants.rankThresholds[nextRank]!;
    
    // Find previous threshold
    int previousThreshold = 0;
    for (final entry in AppConstants.rankThresholds.entries) {
      if (entry.value < nextThreshold && entry.value <= currentPoints) {
        previousThreshold = entry.value;
      }
    }

    final range = nextThreshold - previousThreshold;
    final progress = currentPoints - previousThreshold;
    
    return progress / range;
  }
}
