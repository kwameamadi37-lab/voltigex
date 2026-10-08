import 'package:voltigex/features/dashboard/domain/entities/recent_recipient_entity.dart';

/// Page de virements récents (pagination serveur).
class RecentRecipientsPage {
  const RecentRecipientsPage({
    required this.items,
    required this.hasMore,
    required this.currentPage,
    this.perPage = 25,
  });

  final List<RecentRecipientEntity> items;
  final bool hasMore;
  final int currentPage;
  final int perPage;
}
