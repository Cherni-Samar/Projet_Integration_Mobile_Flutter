import 'dart:convert';
import 'package:characters/characters.dart';
import 'package:e_team/data/dtos/echo_dto.dart';

class EchoFormatters {
  static String humanReadableAutoReplyBody(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return text;
    if (!text.startsWith('{') && !text.startsWith('[')) return raw;

    Map<String, dynamic>? map;

    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) map = decoded;
    } catch (_) {
      try {
        final normalized = text.replaceAll("'", '"');
        final decoded = jsonDecode(normalized);
        if (decoded is Map<String, dynamic>) map = decoded;
      } catch (_) {}
    }

    if (map == null) {
      final singleQuoteSummary =
      RegExp(r"summary\s*:\s*'([^']*)'").firstMatch(text)?.group(1);

      if (singleQuoteSummary != null && singleQuoteSummary.trim().isNotEmpty) {
        return _composeAutoReplyFromAnalysis({
          'summary': singleQuoteSummary.trim(),
        });
      }

      final doubleQuoteSummary =
      RegExp(r'summary\s*:\s*"([^"]*)"').firstMatch(text)?.group(1);

      if (doubleQuoteSummary != null && doubleQuoteSummary.trim().isNotEmpty) {
        return _composeAutoReplyFromAnalysis({
          'summary': doubleQuoteSummary.trim(),
        });
      }

      return raw;
    }

    final direct = map['reply'] ??
        map['replyText'] ??
        map['replyContent'] ??
        map['generatedReply'] ??
        map['emailBody'] ??
        map['body'] ??
        map['message'] ??
        map['text'];

    if (direct != null && direct.toString().trim().isNotEmpty) {
      return direct.toString().trim();
    }

    return _composeAutoReplyFromAnalysis(map);
  }

  static String _composeAutoReplyFromAnalysis(Map<String, dynamic> map) {
    final summary = map['summary']?.toString().trim() ?? '';
    final actions = map['actions'];
    final urgent = map['isUrgent'] == true || map['isUrgent'] == 1;
    final priority = map['priority']?.toString().toLowerCase() ?? '';

    final buffer = StringBuffer();

    buffer.writeln('Bonjour,');
    buffer.writeln();

    if (summary.isNotEmpty) {
      var line = summary.trimRight();
      final endsWell = line.endsWith('.') ||
          line.endsWith('!') ||
          line.endsWith('?') ||
          line.endsWith('…');

      if (!endsWell) line = '$line.';

      buffer.writeln(line);
      buffer.writeln();
    }

    if (actions is List && actions.isNotEmpty) {
      buffer.writeln(
        'Pour la suite, nous vous confirmons la prise en charge des points suivants :',
      );

      for (final action in actions) {
        final item = action.toString().trim();
        if (item.isNotEmpty) buffer.writeln('• $item');
      }

      buffer.writeln();
    }

    if (urgent || priority == 'high') {
      buffer.writeln(
        'Nous traitons votre demande en priorité et vous tiendrons informé(e) dans les meilleurs délais.',
      );
    } else {
      buffer.writeln('Nous restons à votre disposition pour toute précision.');
    }

    final out = buffer.toString().trim();
    return out.isEmpty ? map.toString() : out;
  }

  static bool replySucceeded(Map<String, dynamic> response) {
    final success = response['success'];

    if (success == true || success == 1 || success == 'true') return true;
    if (response['ok'] == true || response['saved'] == true) return true;
    if (response['status'] == 'ok' || response['status'] == 'success') {
      return true;
    }

    return false;
  }

  static bool isMeaningfulMessage(String message) {
    if (message.length < 5) return false;

    const vowels = 'aeiouyAEIOUY';
    const consonants = 'bcdfghjklmnpqrstvwxzBCDFGHJKLMNPQRSTVWXZ';

    int vowelCount = 0;
    int consonantCount = 0;

    for (final char in message.characters) {
      if (vowels.contains(char)) {
        vowelCount++;
      } else if (consonants.contains(char)) {
        consonantCount++;
      }
    }

    if (consonantCount > 0 && vowelCount / consonantCount < 0.2) {
      return false;
    }

    return true;
  }

  static String echoFormattedText(EchoResponse response) {
    String text = '';

    if (response.summary != null) {
      text += '📝 Resume\n${response.summary}\n\n';
    }

    if (response.transcribedText != null) {
      text += '🎤 Message transcrit\n${response.transcribedText}\n\n';
    }

    text += '⚠️ Urgent : ${response.isUrgent ? 'OUI' : 'NON'}\n';
    text += '⭐ Priorite : ${_priorityIcon(response.priority)}\n\n';

    if (response.actions.isNotEmpty) {
      text += '✅ Actions a faire\n';
      for (final action in response.actions) {
        text += '   • $action\n';
      }
    }

    if (response.category != null) {
      text += '\n📂 Categorie : ${response.category}';
    }

    if (response.error != null) {
      text += '❌ Erreur : ${response.error}';
    }

    return text;
  }

  static String _priorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return '🔴 HIGH';
      case 'medium':
        return '🟠 MEDIUM';
      default:
        return '🟢 LOW';
    }
  }
}