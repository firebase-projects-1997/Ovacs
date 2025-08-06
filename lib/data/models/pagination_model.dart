class PaginationModel {
  final int count;
  final int totalPages;
  final int currentPage;
  final String? next;
  final String? previous;

  PaginationModel({
    required this.count,
    required this.totalPages,
    required this.currentPage,
    this.next,
    this.previous,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      count: json['count'],
      totalPages: json['total_pages'],
      currentPage: json['current_page'],
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );
  }
  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;
}
