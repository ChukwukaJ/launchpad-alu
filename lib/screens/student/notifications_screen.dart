import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import '../../widgets/common_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.newApplication:
        return Icons.person_add_alt_1_rounded;
      case NotificationType.statusChange:
        return Icons.update_rounded;
      case NotificationType.newOpportunityMatch:
        return Icons.auto_awesome_rounded;
      case NotificationType.startupVerified:
        return Icons.verified_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthCubit>().state.user!.uid;
    final repo = NotificationRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<AppNotification>>(
        stream: repo.watchNotifications(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingView();
          final notifications = snapshot.data!;
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'You\'re all caught up',
              subtitle: 'New activity on your applications or postings will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final n = notifications[i];
              return Card(
                color: n.read ? Colors.white : AppColors.primary.withOpacity(0.05),
                child: ListTile(
                  onTap: () => repo.markRead(n.id),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(_iconFor(n.type), color: AppColors.primary, size: 20),
                  ),
                  title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(n.body),
                  trailing: Text(timeago.format(n.createdAt, locale: 'en_short'),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
