import 'package:new_ovacs/data/models/client_model.dart';

import 'pagination_model.dart';

class ClientsWithPaginationResponse {
  final List<ClientModel> clients;
  final PaginationModel pagination;

  ClientsWithPaginationResponse({
    required this.clients,
    required this.pagination,
  });
}
