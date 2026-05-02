import 'badge_model.dart';

class PredictionStatsModel {
  final int totalPlayed;
  final int wins;
  final int losses;
  final num winRate;
  final int totalEnergyEarned;
  final int currentStreak;
  final int bestStreak;
  final List<BadgeModel> badges;

  const PredictionStatsModel({
    required this.totalPlayed,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.totalEnergyEarned,
    required this.currentStreak,
    required this.bestStreak,
    required this.badges,
  });

  factory PredictionStatsModel.fromJson(Map<String, dynamic> json) =>
      PredictionStatsModel(
        totalPlayed: (json['totalPlayed'] as num?)?.toInt() ?? 0,
        wins: (json['wins'] as num?)?.toInt() ?? 0,
        losses: (json['losses'] as num?)?.toInt() ?? 0,
        winRate: (json['winRate'] as num?) ?? 0,
        totalEnergyEarned: (json['totalEnergyEarned'] as num?)?.toInt() ?? 0,
        currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
        bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
        badges: (json['badges'] as List? ?? const [])
            .map((e) => BadgeModel.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}
