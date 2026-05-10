import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:e_team/presentation/models/kash/kash_agent_models.dart';

class KashExtractionCard extends StatelessWidget {
  static const _volt = Color(0xFFCDFF00);
  static const _gold = Color(0xFFFFD54F);

  final ExtractedExpense extracted;
  final Uint8List? receiptBytes;
  final VoidCallback onConfirm;

  const KashExtractionCard({
    super.key,
    required this.extracted,
    required this.receiptBytes,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111511),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _volt.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: _gold),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Données extraites',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '${extracted.amount} ${extracted.currency}',
                style: const TextStyle(
                  color: _volt,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (receiptBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.memory(
                receiptBytes!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          if (receiptBytes != null) const SizedBox(height: 10),
          _kv('Fournisseur', extracted.vendor),
          _kv('Catégorie', extracted.category),
          _kv('Date', extracted.dateIso),
          if (extracted.description.isNotEmpty)
            _kv('Description', extracted.description),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _volt,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onConfirm,
              child: const Text(
                'Confirmer et Enregistrer',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              k,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
