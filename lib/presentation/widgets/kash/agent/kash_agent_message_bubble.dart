import 'package:flutter/material.dart';

import 'package:e_team/presentation/models/kash/kash_agent_models.dart';

class KashMessageBubble extends StatelessWidget {
  static const _volt = Color(0xFFCDFF00);
  static const _gold = Color(0xFFFFD54F);

  final KashMessage msg;

  const KashMessageBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    final fromUser = msg.fromUser;
    final bg = fromUser ? const Color(0xFF121A12) : const Color(0xFF111511);
    final border = fromUser
        ? _volt.withValues(alpha: 0.25)
        : Colors.white.withValues(alpha: 0.06);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: fromUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  msg.text,
                  style: TextStyle(
                    color: fromUser ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                if (msg.imageBytes != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _gold.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Image.memory(
                        msg.imageBytes!,
                        width: 180,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
