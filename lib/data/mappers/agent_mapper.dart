// lib/data/mappers/agent_mapper.dart
import 'package:e_team/domain/models/agent_model.dart';
import 'package:e_team/data/dtos/agent_dto.dart';

class AgentMapper {
  static Agent fromDTO(AgentDTO dto) {
    return Agent(
      title: dto.title,
      shortTitle: dto.shortTitle,
      color: dto.color,
      illustration: dto.illustration,
      description: dto.description,
      benefits: dto.benefits,
      detailedFeatures: dto.detailedFeatures,
      timesSaved: dto.timesSaved,
      stats: dto.stats,
      price: dto.price,
      // Ici on applique ta logique de l'ancien constructeur
      name: dto.title,
      category: 'Intelligence', // Exemple de valeur par défaut
      isActive: true,
    );
  }
}
