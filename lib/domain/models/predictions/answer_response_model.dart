import 'answer_result_model.dart';

class AnswerResponseModel {
  final bool success;
  final AnswerResultModel result;

  const AnswerResponseModel({required this.success, required this.result});

  factory AnswerResponseModel.fromJson(Map<String, dynamic> json) =>
      AnswerResponseModel(
        success: json['success'] == true,
        result: AnswerResultModel.fromJson(
          (json['result'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      );
}
