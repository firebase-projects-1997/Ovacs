import 'pagination_model.dart';
import 'case_model.dart';

class CasesWithPaginationResponse {
  final List<CaseModel> cases;
  final PaginationModel pagination;

  CasesWithPaginationResponse({
    required this.cases,
    required this.pagination,
  });
}
