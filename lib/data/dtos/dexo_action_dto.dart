class DexoActionDTO {
  final String id;
  final String actionType;
  final String employeeName;
  final Map<String, dynamic> details;
  final String createdAt;

  DexoActionDTO({required this.id, required this.actionType, required this.employeeName, required this.details, required this.createdAt});

  factory DexoActionDTO.fromJson(Map<String, dynamic> json) {
    return DexoActionDTO(
      id: json['_id'] ?? json['id'] ?? '',
      actionType: json['action_type'] ?? '',
      employeeName: json['employee_name'] ?? 'System',
      details: json['details'] ?? {},
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }
}