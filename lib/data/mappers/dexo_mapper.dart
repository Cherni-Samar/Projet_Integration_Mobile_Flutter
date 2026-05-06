import 'package:e_team/domain/models/dexo_action_model.dart';
import 'package:e_team/data/dtos/dexo_action_dto.dart';

class DexoMapper {
  static DexoAction fromDTO(DexoActionDTO dto) {
    return DexoAction(
      id: dto.id,
      title:
          dto.details['document']?.toString().toUpperCase() ?? "ACTION SYSTEME",
      subtitle: "Certifié par Dexo IA",
      time: dto.createdAt, // On formatera dans la UI
      type: dto.actionType,
    );
  }
}
