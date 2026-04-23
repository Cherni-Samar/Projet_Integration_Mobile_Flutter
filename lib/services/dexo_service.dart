import 'dart:convert';
import 'package:http/http.dart' as http;

class DexoService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/dexo';
  
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
  
  static Future<Map<String, dynamic>> getDocumentsByCategory({
    required String category,
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/documents?category=$category&userId=$userId&limit=$limit&offset=$offset'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur récupération documents: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur récupération documents: $e');
    }
  }
  
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
  
  static List<String> getConfidentialityLevels() {
    return ['public', 'interne', 'confidentiel', 'secret'];
  }
  
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
  
  static bool isFileSupported(String filename) {
    final supportedExtensions = [
      '.pdf', '.doc', '.docx', '.txt', '.csv',
      '.xls', '.xlsx', '.jpg', '.jpeg', '.png', '.gif'
    ];
    
    final extension = filename.toLowerCase().substring(filename.lastIndexOf('.'));
    return supportedExtensions.contains(extension);
  }
  
  static int getMaxFileSize() {
    return 50 * 1024 * 1024;
  }
  
  static String formatFileSize(int bytes) {
    if (bytes == 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    final i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${sizes[i]}';
  }
}
