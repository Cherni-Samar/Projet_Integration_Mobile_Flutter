import 'package:e_team/data/services/api_service.dart';
import 'package:e_team/data/services/auth_service.dart';
import 'package:e_team/utils/constants.dart';

import 'package:e_team/domain/models/predictions/daily_response_model.dart';
import 'package:e_team/domain/models/predictions/answer_response_model.dart';
import 'package:e_team/domain/models/predictions/history_response_model.dart';

class PredictionsService {
  final AuthService _auth = AuthService();

  Future<String?> _token() => _auth.getToken();

  Future<DailyResponseModel> getDaily() async {
    final token = await _token();
    final res = await ApiService.get(
      endpoint: ApiConstants.predictionsDaily,
      token: token,
    );

    // ✅ on ne jette pas d'exception ici si backend renvoie success=false
    return DailyResponseModel.fromJson(res);
  }

  Future<AnswerResponseModel> answer({
    required String predictionId,
    required int answer,
    required String chosenAgent,
  }) async {
    final token = await _token();
    final res = await ApiService.post(
      endpoint: ApiConstants.predictionsAnswer(predictionId),
      token: token,
      body: {'answer': answer, 'chosenAgent': chosenAgent},
    );

    // ✅ pareil: on parse toujours
    return AnswerResponseModel.fromJson(res);
  }

  Future<HistoryResponseModel> history() async {
    final token = await _token();
    final res = await ApiService.get(
      endpoint: ApiConstants.predictionsHistory,
      token: token,
    );
    return HistoryResponseModel.fromJson(res);
  }

  Future<Map<String, dynamic>> resetToday() async {
    final token = await _token();
    final res = await ApiService.post(
      endpoint: ApiConstants.predictionsResetToday,
      token: token,
      body: {},
    );
    return res;
  }
}
