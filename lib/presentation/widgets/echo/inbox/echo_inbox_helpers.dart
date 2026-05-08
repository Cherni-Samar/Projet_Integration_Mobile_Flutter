import 'package:flutter/material.dart';

Color echoSenderColor(String sender) {
  final colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  return colors[sender.length % colors.length];
}

Color echoPriorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return Colors.red;
    case 'medium':
      return Colors.orange;
    default:
      return Colors.green;
  }
}

String echoPriorityText(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return 'Haute';
    case 'medium':
      return 'Moyenne';
    default:
      return 'Basse';
  }
}

String echoFormatTime(DateTime time) {
  final diff = DateTime.now().difference(time);

  if (diff.inDays > 0) return 'il y a ${diff.inDays}j';
  if (diff.inHours > 0) return 'il y a ${diff.inHours}h';
  if (diff.inMinutes > 0) return 'il y a ${diff.inMinutes}min';

  return 'À l’instant';
}

String echoFormatDateTime(DateTime time) {
  final day = time.day.toString().padLeft(2, '0');
  final month = time.month.toString().padLeft(2, '0');
  final year = time.year;
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');

  return '$day/$month/$year à $hour:$minute';
}
