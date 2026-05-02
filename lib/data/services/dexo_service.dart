import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

class DexoService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api/dexo';

  // ═══════════════════════════════════════════════════════════════
  // 📂 DOCUMENT CATEGORY MANAGEMENT
  // ═══════════════════════════════════════════════════════════════

  // Récupérer les documents par catégorie
  static Future<Map<String, dynamic>> getDocumentsByCategory({
    required String category,
    String? userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'category': category,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (userId != null) {
        queryParams['userId'] = userId;
      }

      final uri = Uri.parse('$baseUrl/documents-by-category')
          .replace(queryParameters: queryParams);
      final token = await AuthService().getToken();
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token ?? '',
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur récupération documents: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur récupération documents par catégorie: $e');
    }
  }

  // Récupérer le contenu d'un document
  static Future<Map<String, dynamic>> getDocumentContent({
    required String documentId,
    String? userId,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (userId != null) {
        queryParams['userId'] = userId;
      }

      final uri = Uri.parse('$baseUrl/document-content/$documentId')
          .replace(queryParameters: queryParams);
      final token = await AuthService().getToken();
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token ?? '',
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur récupération contenu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur récupération contenu document: $e');
    }
  }

  // Mettre à jour les paramètres de workforce
  static Future<Map<String, dynamic>> updateWorkforceSettings(
      Map<String, dynamic> data) async {
    final token = await AuthService().getToken();
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/dexo/workforce-settings'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token ?? '',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // Obtenir des conseils stratégiques via l'IA Dexo
  static Future<Map<String, dynamic>> getStrategicAdvice(
      Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/dexo/strategic-advice'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return jsonDecode(response.body);
  }

  // Sauvegarder la vision organisationnelle
  static Future<Map<String, dynamic>> saveVision(
      Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/dexo/save-vision'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return jsonDecode(response.body);
  }

  // ═══════════════════════════════════════════════════════════════
  // 🛠️ UTILITY / STATIC HELPERS (no HTTP calls)
  // ═══════════════════════════════════════════════════════════════

  // Obtenir les types de documents supportés
  static List<String> getSupportedDocumentTypes() {
    return [
      'contrat_service',
      'contrat_partenariat',
      'rapport_incident',
      'rapport_audit',
      'politique_securite',
      'procedure_qualite',
      'facture',
      'devis',
      'bon_commande',
      'presentation_commerciale',
      'document_technique',
      'manuel_utilisateur',
    ];
  }

  // Obtenir les niveaux de confidentialité
  static List<String> getConfidentialityLevels() {
    return ['public', 'interne', 'confidentiel', 'secret'];
  }

  // Obtenir les catégories de documents
  static List<String> getDocumentCategories() {
    return [
      'contrats',
      'factures',
      'rapports',
      'presentations',
      'juridique',
      'rh',
      'technique',
      'marketing',
      'finance',
      'autre'
    ];
  }

  // Obtenir les rôles d'accès
  static List<String> getAccessRoles() {
    return [
      'admin',
      'manager',
      'employee',
      'hr',
      'finance',
      'legal',
      'marketing',
      'technical'
    ];
  }

  // Valider un fichier avant upload
  static bool isFileSupported(String filename) {
    final supportedExtensions = [
      '.pdf', '.doc', '.docx', '.txt', '.csv',
      '.xls', '.xlsx', '.jpg', '.jpeg', '.png', '.gif'
    ];
    final extension =
        filename.toLowerCase().substring(filename.lastIndexOf('.'));
    return supportedExtensions.contains(extension);
  }

  // Obtenir la taille maximale de fichier (en bytes)
  static int getMaxFileSize() {
    return 50 * 1024 * 1024; // 50MB
  }

  // Formater la taille de fichier
  static String formatFileSize(int bytes) {
    if (bytes == 0) return '0 Bytes';
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    final i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${sizes[i]}';
  }

  // Obtenir l'icône pour un type de fichier
  static String getFileIcon(String filename) {
    final extension =
        filename.toLowerCase().substring(filename.lastIndexOf('.'));
    switch (extension) {
      case '.pdf':
        return '📄';
      case '.doc':
      case '.docx':
        return '📝';
      case '.xls':
      case '.xlsx':
        return '📊';
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return '🖼️';
      case '.txt':
        return '📃';
      case '.csv':
        return '📋';
      default:
        return '📁';
    }
  }

  // Obtenir la couleur pour un niveau de priorité
  static String getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return '#FF0000';
      case 'high':
        return '#FF6600';
      case 'medium':
        return '#FFCC00';
      case 'low':
        return '#00CC00';
      default:
        return '#CCCCCC';
    }
  }

  // Obtenir la couleur pour un niveau de confidentialité
  static String getConfidentialityColor(String level) {
    switch (level.toLowerCase()) {
      case 'secret':
        return '#8B0000';
      case 'confidentiel':
        return '#FF4500';
      case 'interne':
        return '#FFA500';
      case 'public':
        return '#32CD32';
      default:
        return '#CCCCCC';
    }
  }

  // Obtenir les départements disponibles
  static List<String> getDepartments() {
    return ['RH', 'Finance', 'Juridique', 'Technique', 'Marketing', 'Commercial'];
  }

  // Obtenir les types de documents avancés
  static List<String> getAdvancedDocumentTypes() {
    return ['contrat', 'facture', 'rapport', 'presentation', 'politique', 'procedure'];
  }

  // Obtenir les niveaux de confidentialité avancés
  static Map<String, Map<String, dynamic>> getAdvancedConfidentialityLevels() {
    return {
      'public': {'level': 0, 'color': '#4CAF50', 'roles': ['all']},
      'interne': {
        'level': 1,
        'color': '#FF9800',
        'roles': ['employee', 'manager', 'admin']
      },
      'confidentiel': {
        'level': 2,
        'color': '#F44336',
        'roles': ['manager', 'admin']
      },
      'critique': {'level': 3, 'color': '#9C27B0', 'roles': ['admin']},
    };
  }

  // Obtenir les types d'événements de sécurité
  static List<String> getSecurityEventTypes() {
    return [
      'document_upload',
      'document_access',
      'document_download',
      'document_share',
      'unauthorized_access_attempt',
      'suspicious_behavior',
      'security_alert',
      'document_expired',
      'duplicate_detected'
    ];
  }

  // Obtenir les actions possibles
  static List<String> getSecurityActions() {
    return ['read', 'write', 'delete', 'share', 'upload', 'download'];
  }

  // Formater les métriques de sécurité
  static String formatSecurityScore(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Bon';
    if (score >= 60) return 'Moyen';
    if (score >= 40) return 'Faible';
    return 'Critique';
  }

  // Obtenir la couleur du score de sécurité
  static String getSecurityScoreColor(int score) {
    if (score >= 90) return '#4CAF50';
    if (score >= 75) return '#8BC34A';
    if (score >= 60) return '#FFC107';
    if (score >= 40) return '#FF9800';
    return '#F44336';
  }

  // Formater la durée depuis un timestamp
  static String formatTimeSince(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  // Obtenir l'icône pour un type d'événement
  static String getEventTypeIcon(String eventType) {
    switch (eventType) {
      case 'document_upload':
        return '📤';
      case 'document_access':
        return '👁️';
      case 'document_download':
        return '📥';
      case 'document_share':
        return '🔗';
      case 'unauthorized_access_attempt':
        return '🚫';
      case 'suspicious_behavior':
        return '⚠️';
      case 'security_alert':
        return '🚨';
      case 'document_expired':
        return '⏰';
      case 'duplicate_detected':
        return '🔄';
      default:
        return '📋';
    }
  }
}
