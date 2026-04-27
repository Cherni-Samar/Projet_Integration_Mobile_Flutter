import 'prediction_history_item_model.dart';
import 'prediction_stats_model.dart';

class HistoryResponseModel {
  final bool success;
  final PredictionStatsModel stats;
  final List<PredictionHistoryItemModel> history;

  const HistoryResponseModel({
    required this.success,
    required this.stats,
    required this.history,
  });

  factory HistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      HistoryResponseModel(
        success: json['success'] == true,
        stats: PredictionStatsModel.fromJson(
          (json['stats'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        history: (json['history'] as List? ?? const [])
            .map(
              (e) => PredictionHistoryItemModel.fromJson(
                (e as Map).cast<String, dynamic>(),
              ),
            )
            .toList(),
      );
}
