class SessionModel {
  final int id;
  final String? title;
  final String? description;
  final String? time;
  final DateTime? date;
  final int? createdBy;
  final bool? isActive;
  final String? caseTitle;
  final String? clientName;
  final int? clientId;
  final int? caseId;

  const SessionModel({
    required this.id,
    this.title,
    this.description,
    this.time,
    this.date,
    this.createdBy,
    this.isActive,
    this.caseTitle,
    this.clientName,
    this.clientId,
    this.caseId,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] ?? 0,
      title: json['title'] as String?,
      description: json.containsKey('description')
          ? json['description'] as String?
          : null,
      time: json.containsKey('time') ? json['time'] as String? : null,
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      createdBy: json.containsKey('created_by')
          ? json['created_by'] as int?
          : null,
      isActive: json.containsKey('is_active')
          ? json['is_active'] as bool?
          : null,
      caseTitle: json.containsKey('case_title')
          ? json['case_title'] as String?
          : null,
      clientName: json.containsKey('client_name')
          ? json['client_name'] as String?
          : null,
      clientId: json.containsKey('client_id')
          ? json['client_id'] as int?
          : null,
      caseId: json.containsKey('case_id') ? json['case_id'] as int? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
      'date': date?.toUtc().toIso8601String(),
      'created_by': createdBy,
      'is_active': isActive,
      'case_title': caseTitle,
      'client_name': clientName,
      'client_id': clientId,
      'case_id': caseId,
    };
  }
}
