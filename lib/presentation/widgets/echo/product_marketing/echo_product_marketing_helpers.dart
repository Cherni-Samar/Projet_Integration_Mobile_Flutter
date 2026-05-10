String formatCampaignFrequency(String frequency) {
  switch (frequency) {
    case 'daily':
      return 'Every Day';
    case '3days':
      return 'Every 3 Days';
    case 'weekly':
      return 'Every Week';
    default:
      return frequency;
  }
}

String formatCampaignDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    return 'Today';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
  } else {
    final months = (difference.inDays / 30).floor();
    return '$months ${months == 1 ? 'month' : 'months'} ago';
  }
}
