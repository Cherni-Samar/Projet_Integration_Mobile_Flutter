import 'package:flutter/material.dart';

Color getActivityStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'success':
      return Colors.green;
    case 'failed':
      return Colors.red;
    case 'pending':
      return Colors.orange;
    case 'in_progress':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

Color getActivityPriorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return Colors.red;
    case 'medium':
      return Colors.orange;
    case 'low':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

String formatActivityTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else {
    return '${difference.inDays}d ago';
  }
}
