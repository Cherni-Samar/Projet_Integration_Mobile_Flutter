import 'package:e_team/presentation/widgets/common/app_loading.dart';
import 'package:flutter/material.dart';

import 'package:e_team/data/services/hera_service.dart';
import 'package:e_team/domain/models/hera/hera_models.dart';
import 'package:e_team/presentation/widgets/hera/hera_shared_widgets.dart';

class HeraEmployeeDocumentsSheet extends StatelessWidget {
  const HeraEmployeeDocumentsSheet({
    super.key,
    required this.employee,
    required this.onViewDocument,
    required this.onGeneratePdf,
  });

  final HeraEmployee employee;
  final ValueChanged<Map<String, dynamic>> onViewDocument;
  final void Function(String title, String content) onGeneratePdf;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setSheet) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: HeraPalette.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Documents · ${employee.name}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Divider(color: HeraPalette.border, height: 24),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: HeraService.getHistory(employeeId: employee.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: AppLoadingIndicator(color: HeraPalette.mauve),
                    );
                  }

                  final response = snapshot.data ?? {};
                  final actions = response['actions'] as List? ?? [];
                  final docs = actions.where(_isDocumentAction).toList();

                  if (docs.isEmpty) {
                    return Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await HeraService.generateHeraDoc(
                            employeeId: employee.id,
                            docType: 'contract',
                          );
                          setSheet(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HeraPalette.mauve,
                        ),
                        child: const Text(
                          'Générer le contrat via Hera',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: docs.length,
                    itemBuilder: (_, index) {
                      final doc = Map<String, dynamic>.from(docs[index]);
                      return HeraDocumentTile(
                        doc: doc,
                        onView: () => onViewDocument(doc),
                        onDownload: () {
                          final isContract =
                              doc['action_type'] == 'contract_renewal';
                          onGeneratePdf(
                            isContract ? 'Contrat' : 'Bulletin',
                            doc['details']?['content'] ?? '',
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isDocumentAction(Object? action) {
    if (action is! Map) return false;
    final type = action['action_type'];
    return type == 'contract_renewal' || type == 'performance_alert';
  }
}

class HeraDocumentTile extends StatelessWidget {
  const HeraDocumentTile({
    super.key,
    required this.doc,
    required this.onView,
    required this.onDownload,
  });

  final Map<String, dynamic> doc;
  final VoidCallback onView;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final isContract = doc['action_type'] == 'contract_renewal';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HeraPalette.cardSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HeraPalette.mauve.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isContract ? Icons.description : Icons.payments,
            color: HeraPalette.mauve,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isContract ? 'CONTRAT DE TRAVAIL' : 'BULLETIN DE PAIE',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.visibility_outlined,
              color: HeraPalette.mauve,
            ),
            onPressed: onView,
          ),
          IconButton(
            icon: const Icon(
              Icons.file_download_outlined,
              color: HeraPalette.lime,
            ),
            onPressed: onDownload,
          ),
        ],
      ),
    );
  }
}
