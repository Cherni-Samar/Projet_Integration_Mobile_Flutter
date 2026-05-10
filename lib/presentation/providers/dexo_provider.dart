import 'package:flutter/foundation.dart';

import 'package:e_team/data/services/dexo_service.dart';

class DexoProvider extends ChangeNotifier {
  bool _loadingDocuments = false;
  bool _savingVision = false;
  String? _error;

  List<Map<String, dynamic>> _documents = [];
  Map<String, dynamic>? _selectedDocumentContent;

  bool get loadingDocuments => _loadingDocuments;
  bool get savingVision => _savingVision;
  bool get isLoading => _loadingDocuments || _savingVision;
  String? get error => _error;
  List<Map<String, dynamic>> get documents => List.unmodifiable(_documents);
  Map<String, dynamic>? get selectedDocumentContent => _selectedDocumentContent;

  Future<void> loadDocumentsByCategory({
    required String category,
    String? userId,
    int limit = 20,
    int offset = 0,
  }) async {
    _loadingDocuments = true;
    _error = null;
    notifyListeners();

    try {
      final response = await DexoService.getDocumentsByCategory(
        category: category,
        userId: userId,
        limit: limit,
        offset: offset,
      );
      _documents = List<Map<String, dynamic>>.from(
        response['documents'] ?? response['data']?['documents'] ?? [],
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingDocuments = false;
      notifyListeners();
    }
  }

  Future<void> loadDocumentContent({
    required String documentId,
    String? userId,
  }) async {
    _loadingDocuments = true;
    _error = null;
    notifyListeners();

    try {
      _selectedDocumentContent = await DexoService.getDocumentContent(
        documentId: documentId,
        userId: userId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingDocuments = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> saveVision(Map<String, dynamic> payload) async {
    _savingVision = true;
    _error = null;
    notifyListeners();

    try {
      return await DexoService.saveVision(payload);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _savingVision = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}
