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
      caseTitle: json['case_title'] as String?,
      clientName: json['client_name'] as String?,
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
    };
  }
}
