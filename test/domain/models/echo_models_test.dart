import 'package:flutter_test/flutter_test.dart';
import 'package:e_team/domain/models/echo_models.dart';

void main() {
  group('domain/models/echo_models', () {
    group('PostStats', () {
      test('totalEngagement sums likes + comments + shares', () {
        const stats = PostStats(likes: 10, comments: 3, shares: 2);
        expect(stats.totalEngagement, 15);
      });
    });

    group('PendingItem', () {
      test('isStillScheduled is false when emailId is empty', () {
        final item = PendingItem(
          emailId: '',
          subject: 's',
          sender: 'a',
          scheduledAt: DateTime.now().add(const Duration(minutes: 10)),
          remainingMinutes: 10,
          willSendIn: '',
        );

        expect(item.isStillScheduled, false);
        expect(item.displayWillSendIn, '');
      });

      test('isStillScheduled is true when scheduledAt is in the future', () {
        final item = PendingItem(
          emailId: 'e1',
          subject: 's',
          sender: 'a',
          scheduledAt: DateTime.now().add(const Duration(minutes: 10)),
          remainingMinutes: 0,
          willSendIn: '',
        );

        expect(item.isStillScheduled, true);
      });

      test('displayWillSendIn uses willSendIn if provided', () {
        final item = PendingItem(
          emailId: 'e1',
          subject: 's',
          sender: 'a',
          scheduledAt: DateTime.now().add(const Duration(minutes: 10)),
          remainingMinutes: 10,
          willSendIn: 'in 10 minutes',
        );

        expect(item.displayWillSendIn, 'in 10 minutes');
      });

      test('displayWillSendIn falls back to computed minutes', () {
        final item = PendingItem(
          emailId: 'e1',
          subject: 's',
          sender: 'a',
          scheduledAt: DateTime.now().add(const Duration(minutes: 2)),
          remainingMinutes: 2,
          willSendIn: '',
        );

        // can be "1 minute" or "2 minutes" depending on ceil and timing,
        // so we assert it’s not empty and contains "minute"
        final text = item.displayWillSendIn;
        expect(text.isNotEmpty, true);
        expect(text.contains('minute'), true);
      });
    });

    group('TaskItem', () {
      test('isOverdue true when deadline in past and status not completed', () {
        final task = TaskItem(
          id: 't1',
          title: 'Do something',
          description: 'desc',
          category: 'cat',
          priority: 'high',
          status: 'todo',
          confidence: 0.9,
          createdAt: DateTime.now(),
          deadline: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(task.isOverdue, true);
      });

      test('isOverdue false when status indicates completed', () {
        final task = TaskItem(
          id: 't1',
          title: 'Done task',
          description: 'desc',
          category: 'cat',
          priority: 'low',
          status: 'done',
          confidence: 0.9,
          createdAt: DateTime.now(),
          deadline: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(task.isOverdue, false);
      });
    });

    group('EmailItem', () {
      test('copyWith changes only isRead', () {
        final email = EmailItem(
          id: 'e1',
          subject: 'Hello',
          sender: 'boss@company.com',
          content: 'content',
          summary: 'sum',
          isUrgent: false,
          isSpam: false,
          priority: 'low',
          actions: const ['reply'],
          category: 'work',
          receivedAt: DateTime.now(),
          isRead: false,
        );

        final updated = email.copyWith(isRead: true);

        expect(updated.isRead, true);
        expect(updated.id, 'e1'); // unchanged
        expect(updated.subject, 'Hello');
      });
    });
  });
}
