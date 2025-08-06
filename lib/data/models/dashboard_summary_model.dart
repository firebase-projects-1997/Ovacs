class DashboardSummaryModel {
  final int totalClients;
  final int totalCases;
  final int totalDocuments;
  final double spaceUsedPercentage;

  DashboardSummaryModel({
    required this.totalClients,
    required this.totalCases,
    required this.totalDocuments,
    required this.spaceUsedPercentage,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalClients: json['total_clients'],
      totalCases: json['total_cases'],
      totalDocuments: json['total_documents'],
      spaceUsedPercentage: json['space_used_percentage'],
    );
  }
}
