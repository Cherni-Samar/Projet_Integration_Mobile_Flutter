import 'package:flutter/foundation.dart';
import 'package:e_team/data/services/predictions_service.dart';
import 'package:e_team/domain/models/predictions/daily_response_model.dart';
import 'package:e_team/domain/models/predictions/answer_response_model.dart';
import 'package:e_team/domain/models/predictions/history_response_model.dart';

class PredictionsProvider extends ChangeNotifier {
  final PredictionsService _service = PredictionsService();

  bool loadingDaily = false;
  bool loadingHistory = false;
  bool submitting = false;

  String? error;
  String? dailyMessage; // ✅ message serveur type "Déjà répondu"

  DailyResponseModel? daily;
  HistoryResponseModel? historyRes;
  AnswerResponseModel? lastAnswer;

  Future<void> fetchDaily() async {
    loadingDaily = true;
    error = null;
    dailyMessage = null;
    notifyListeners();

    try {
      daily = await _service.getDaily();
      if (daily?.error != null) {
        dailyMessage = daily!.error;
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loadingDaily = false;
      notifyListeners();
    }
  }

  Future<void> fetchHistory() async {
    loadingHistory = true;
    error = null;
    notifyListeners();
    try {
      historyRes = await _service.history();
    } catch (e) {
      error = e.toString();
    } finally {
      loadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> submitAnswer({
    required String predictionId,
    required int answer,
    required String chosenAgent,
  }) async {
    submitting = true;
    error = null;
    notifyListeners();

    try {
      lastAnswer = await _service.answer(
        predictionId: predictionId,
        answer: answer,
        chosenAgent: chosenAgent,
      );

      // Si backend renvoie success=false, on garde le message et on ne casse pas l'écran
      if (lastAnswer?.success != true) {
        error = lastAnswer?.result.message.isNotEmpty == true
            ? lastAnswer!.result.message
            : "Impossible d'envoyer la réponse.";
        return;
      }

      await fetchHistory();
      await fetchDaily();
    } catch (e) {
      error = e.toString();
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}
