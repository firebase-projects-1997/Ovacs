
import 'package:new_ovacs/data/models/document_model.dart';

import 'pagination_model.dart';

class DocumentsWithPaginationResponse {
  final List<DocumentModel> documents;
  final PaginationModel pagination;

  DocumentsWithPaginationResponse({
    required this.documents,
    required this.pagination,
  });
}
