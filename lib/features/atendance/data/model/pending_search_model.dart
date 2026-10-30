import 'package:hive/hive.dart';

part 'pending_search_model.g.dart';

@HiveType(typeId: 8)
class PendingSearchModel extends HiveObject {
  @HiveField(0)
  final String pendingKey;

  @HiveField(1)
  final String searchValue;

  @HiveField(2)
  final String sessionId;

  @HiveField(3)
  final String sessionName;

  @HiveField(4)
  String status; // 'pending', 'searching', 'found', 'notFound', 'attendancePending', 'completed', 'failed'

  @HiveField(5)
  final DateTime createdAt;

  PendingSearchModel({
    required this.pendingKey,
    required this.searchValue,
    required this.sessionId,
    required this.sessionName,
    required this.status,
    required this.createdAt,
  });
}
