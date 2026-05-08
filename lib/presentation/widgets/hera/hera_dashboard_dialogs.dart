import 'package:e_team/data/services/hera_service.dart';
import 'package:e_team/domain/models/hera_models.dart';
import 'package:e_team/presentation/widgets/hera/hera_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeraActionDetailDialog extends StatelessWidget {
  const HeraActionDetailDialog({super.key, required this.action});

  final Map<String, dynamic> action;

  @override
  Widget build(BuildContext context) {
    final details = action['details'] is Map<String, dynamic>
        ? action['details'] as Map<String, dynamic>
        : <String, dynamic>{};

    final date = action['created_at'] != null
        ? DateFormat(
            'dd MMMM yyyy · HH:mm',
            'fr_FR',
          ).format(DateTime.parse(action['created_at']))
        : 'Date inconnue';

    return AlertDialog(
      backgroundColor: HeraPalette.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Row(
        children: [
          Icon(Icons.auto_awesome, color: HeraPalette.mauve, size: 18),
          SizedBox(width: 10),
          Text(
            'Détails',
            style: TextStyle(color: HeraPalette.textPrimary, fontSize: 16),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type : ${action['action_type'] ?? '—'}',
              style: const TextStyle(
                color: HeraPalette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: const TextStyle(
                color: HeraPalette.textMuted,
                fontSize: 11,
              ),
            ),
            const Divider(color: HeraPalette.border, height: 24),
            ...details.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: HeraPalette.textPrimary,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: '${entry.key} : ',
                        style: const TextStyle(
                          color: HeraPalette.mauve,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: '${entry.value}'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Fermer',
            style: TextStyle(color: HeraPalette.textMuted),
          ),
        ),
      ],
    );
  }
}

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
                      child: CircularProgressIndicator(
                        color: HeraPalette.mauve,
                      ),
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

class HeraDocumentPreviewSheet extends StatelessWidget {
  const HeraDocumentPreviewSheet({
    super.key,
    required this.title,
    required this.content,
    required this.onDownload,
  });

  final String title;
  final String content;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.88,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'APERÇU · ${title.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    content.replaceAll('*', ''),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontFamily: 'serif',
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: HeraPalette.lime,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.file_download),
                label: const Text(
                  'TÉLÉCHARGER EN PDF',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                onPressed: onDownload,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
