import 'pagination_model.dart';
import 'session_model.dart';

class SessionsWithPaginationResponse {
  final List<SessionModel> sessions;
  final PaginationModel pagination;

  SessionsWithPaginationResponse({
    required this.sessions,
    required this.pagination,
  });
}
