class DocumentModel {
  final int id;
  final int account;
  final int client;
  final int? caseId;
  final int? session;
  final int? group;
  final String clientName;
  final String? caseTitle;
  final String? sessionTitle;
  final String securityLevel;
  final String fileName;
  final int fileSize;
  final String secureViewUrl;
  final String secureDownloadUrl;
  final int uploadedBy;
  final int? orderInGroup;
  final String createdAt;
  final bool isActive;
  final String? groupName;

  DocumentModel({
    required this.id,
    required this.account,
    required this.client,
    required this.clientName,
    required this.securityLevel,
    required this.fileName,
    required this.fileSize,
    required this.secureViewUrl,
    required this.secureDownloadUrl,
    required this.uploadedBy,
    required this.createdAt,
    required this.isActive,
    this.caseId,
    this.session,
    this.group,
    this.caseTitle,
    this.sessionTitle,
    this.orderInGroup,
    this.groupName,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      account: json['account'],
      client: json['client'],
      caseId: json['case'],
      session: json['session'],
      group: json['group'],
      groupName: json['group_name'],
      clientName: json['client_name'],
      caseTitle: json['case_title'],
      sessionTitle: json['session_title'],
      securityLevel: json['security_level'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
      secureViewUrl: json['secure_view_url'],
      secureDownloadUrl: json['secure_download_url'],
      uploadedBy: json['uploaded_by'],
      orderInGroup: json['order_in_group'],
      createdAt: json['created_at'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account': account,
      'client': client,
      'case': caseId,
      'session': session,
      'group': group,
      'group_name': groupName,
      'client_name': clientName,
      'case_title': caseTitle,
      'session_title': sessionTitle,
      'security_level': securityLevel,
      'file_name': fileName,
      'file_size': fileSize,
      'secure_view_url': secureViewUrl,
      'secure_download_url': secureDownloadUrl,
      'uploaded_by': uploadedBy,
      'order_in_group': orderInGroup,
      'created_at': createdAt,
      'is_active': isActive,
    };
  }
}
