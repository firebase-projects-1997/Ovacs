import 'package:new_ovacs/data/models/message_model.dart';
import 'pagination_model.dart';

class MessagesWithPaginationResponse {
  final List<MessageModel> messages;
  final PaginationModel pagination;

  MessagesWithPaginationResponse({
    required this.messages,
    required this.pagination,
  });
}
