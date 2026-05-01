import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class DexoService {
  static const String baseUrl = 'http://192.168.1.102:3000/api/dexo';

  // Upload functionality removed - uploadDocument method disabled

  // Classification automatique d'un document
  static Future<Map<String, dynamic>> classifyDocument({
    required String filename,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/classify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'filename': filename,
          'content': content,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur classification: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur classification document: $e');
    }
  }

  // File classification functionality removed - classifyDocumentFile method disabled

  // Recherche intelligente en langage naturel
  static Future<Map<String, dynamic>> intelligentSearch({
    required String query,
    String userRole = 'employee',
    Map<String, dynamic>? context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'userRole': userRole,
          'context': context ?? {},
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur recherche: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur recherche intelligente: $e');
    }
  }

  // Vérification de sécurité pour un accès document
  static Future<Map<String, dynamic>> checkSecurity({
    required String event,
    required String user,
    required String document,
    required String action,
    Map<String, dynamic>? context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/security-check'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'event': event,
          'user': user,
          'document': document,
          'action': action,
          'context': context ?? {},
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur vérification sécurité: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur vérification sécurité: $e');
    }
  }

  // Génération automatique de document
  static Future<Map<String, dynamic>> generateDocument({
    required String documentType,
    required String requirements,
    Map<String, dynamic>? data,
    String format = 'markdown',
    String language = 'français',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-document'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'documentType': documentType,
          'requirements': requirements,
          'data': data ?? {},
          'format': format,
          'language': language,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur génération: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur génération document: $e');
    }
  }

  // Détection de doublons
  static Future<Map<String, dynamic>> detectDuplicates({
    required String filename,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/detect-duplicates'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'filename': filename,
          'content': content,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur détection doublons: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur détection doublons: $e');
    }
  }

  // Création d'une nouvelle version de document
  static Future<Map<String, dynamic>> createVersion({
    required String filename,
    required String content,
    required String userId,
    String comment = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create-version'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'filename': filename,
          'content': content,
          'userId': userId,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur création version: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur création version: $e');
    }
  }

  // Vérification des documents expirés
  static Future<Map<String, dynamic>> checkExpirations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/check-expirations'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur vérification expirations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur vérification expirations: $e');
    }
  }

  // Vérification de l'état de l'agent Dexo
  static Future<Map<String, dynamic>> getHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur health check: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur health check: $e');
    }
  }

  // Méthodes utilitaires

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

    final extension = filename.toLowerCase().substring(filename.lastIndexOf('.'));
    return supportedExtensions.contains(extension);
  }

  // Obtenir la taille maximale de fichier (en bytes)
  static int getMaxFileSize() {
    return 50 * 1024 * 1024; // 50MB
  }

  // Formater la taille de fichier
  static String formatFileSize(int bytes) {
    if (bytes == 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    final i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${sizes[i]}';
  }

  // Obtenir l'icône pour un type de fichier
  static String getFileIcon(String filename) {
    final extension = filename.toLowerCase().substring(filename.lastIndexOf('.'));

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
        return '#FF0000'; // Rouge
      case 'high':
        return '#FF6600'; // Orange
      case 'medium':
        return '#FFCC00'; // Jaune
      case 'low':
        return '#00CC00'; // Vert
      default:
        return '#CCCCCC'; // Gris
    }
  }

  // Obtenir la couleur pour un niveau de confidentialité
  static String getConfidentialityColor(String level) {
    switch (level.toLowerCase()) {
      case 'secret':
        return '#8B0000'; // Rouge foncé
      case 'confidentiel':
        return '#FF4500'; // Rouge-orange
      case 'interne':
        return '#FFA500'; // Orange
      case 'public':
        return '#32CD32'; // Vert
      default:
        return '#CCCCCC'; // Gris
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔒 ADVANCED SECURITY FEATURES
  // ═══════════════════════════════════════════════════════════════

  // Génération de nom intelligent
  static Future<Map<String, dynamic>> generateIntelligentName({
    required String content,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? classification,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-intelligent-name'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'content': content,
          'metadata': metadata ?? {},
          'classification': classification,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur génération nom intelligent: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur génération nom intelligent: $e');
    }
  }

  // Vérification des permissions d'accès (RBAC)
  static Future<Map<String, dynamic>> checkAccessPermissions({
    required String userId,
    required String documentId,
    String action = 'read',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check-access-permissions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'documentId': documentId,
          'action': action,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur vérification permissions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur vérification permissions: $e');
    }
  }

  // Création de lien de partage sécurisé
  static Future<Map<String, dynamic>> createSecureShareLink({
    required String documentId,
    required String userId,
    Map<String, dynamic>? options,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create-secure-share-link'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'documentId': documentId,
          'userId': userId,
          'options': options ?? {},
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur création lien sécurisé: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur création lien sécurisé: $e');
    }
  }

  // Détection avancée de doublons
  static Future<Map<String, dynamic>> detectAdvancedDuplicates({
    required String filename,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/detect-advanced-duplicates'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'filename': filename,
          'content': content,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur détection avancée doublons: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur détection avancée doublons: $e');
    }
  }

  // Journalisation des événements de sécurité
  static Future<Map<String, dynamic>> logSecurityEvent({
    required String eventType,
    required String userId,
    required String documentId,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/log-security-event'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'eventType': eventType,
          'userId': userId,
          'documentId': documentId,
          'action': action,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur journalisation sécurité: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur journalisation sécurité: $e');
    }
  }

  // Analyse comportementale des patterns suspects
  static Future<Map<String, dynamic>> analyzeSuspiciousPatterns({
    required String userId,
    int hours = 24,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze-suspicious-patterns'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'hours': hours,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur analyse comportementale: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur analyse comportementale: $e');
    }
  }

  // Scan de sécurité périodique
  static Future<Map<String, dynamic>> performSecurityScan() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/perform-security-scan'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur scan sécurité: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur scan sécurité: $e');
    }
  }

  // Scan des expirations
  static Future<Map<String, dynamic>> performExpirationScan() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/perform-expiration-scan'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur scan expiration: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur scan expiration: $e');
    }
  }

  // Traitement avancé de document
  static Future<Map<String, dynamic>> processDocumentAdvanced({
    required String filename,
    required String content,
    required String userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/process-document-advanced'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'filename': filename,
          'content': content,
          'userId': userId,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur traitement avancé: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur traitement avancé: $e');
    }
  }

  // Obtenir les logs d'audit
  static Future<Map<String, dynamic>> getAuditLogs({
    String? userId,
    String? documentId,
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };

      if (userId != null) queryParams['userId'] = userId;
      if (documentId != null) queryParams['documentId'] = documentId;
      if (eventType != null) queryParams['eventType'] = eventType;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final uri = Uri.parse('$baseUrl/audit-logs').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur récupération logs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur récupération logs: $e');
    }
  }

  // Obtenir les métriques de sécurité
  static Future<Map<String, dynamic>> getSecurityMetrics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/security-metrics'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur métriques sécurité: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur métriques sécurité: $e');
    }
  }

  // Obtenir le dashboard de sécurité
  static Future<Map<String, dynamic>> getSecurityDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/security-dashboard'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur dashboard sécurité: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur dashboard sécurité: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🛠️ UTILITY METHODS FOR ADVANCED FEATURES
  // ═══════════════════════════════════════════════════════════════

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
      'interne': {'level': 1, 'color': '#FF9800', 'roles': ['employee', 'manager', 'admin']},
      'confidentiel': {'level': 2, 'color': '#F44336', 'roles': ['manager', 'admin']},
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
    if (score >= 90) return '#4CAF50'; // Vert
    if (score >= 75) return '#8BC34A'; // Vert clair
    if (score >= 60) return '#FFC107'; // Jaune
    if (score >= 40) return '#FF9800'; // Orange
    return '#F44336'; // Rouge
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

  // ═══════════════════════════════════════════════════════════════
  // 📤 DOCUMENT UPLOAD AND SAVE FUNCTIONALITY
  // ═══════════════════════════════════════════════════════════════

  // Document save functionality removed - saveClassifiedDocument method disabled

  // File save functionality removed - saveClassifiedFile method disabled

  // ═══════════════════════════════════════════════════════════════
  // 💾 DOCUMENT SAVE FUNCTIONALITY
  // ═══════════════════════════════════════════════════════════════

  // Sauvegarder un document classifié dans la base de données
  static Future<Map<String, dynamic>> saveClassifiedDocument({
    required String filename,
    required String content,
    required Map<String, dynamic> classification,
    required String userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save-classified-document'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'filename': filename,
          'content': content,
          'classification': classification,
          'userId': userId,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur sauvegarde: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur sauvegarde document classifié: $e');
    }
  }

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

      final uri = Uri.parse('$baseUrl/documents-by-category').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

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

      final uri = Uri.parse('$baseUrl/document-content/$documentId').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur récupération contenu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur récupération contenu document: $e');
    }
  }
}