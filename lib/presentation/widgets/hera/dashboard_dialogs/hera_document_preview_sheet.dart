import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/hera/hera_shared_widgets.dart';

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
