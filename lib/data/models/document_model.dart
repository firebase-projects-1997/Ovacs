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
      id: json['id'] as int,
      account: json['account'] as int,
      client: json['client'] as int,
      caseId: json['case'] as int?,
      session: json['session'] as int?,
      group: json['group'] as int?,
      groupName: json['group_name'] as String?,
      clientName: json['client_name'] as String,
      caseTitle: json['case_title'] as String?,
      sessionTitle: json['session_title'] as String?,
      securityLevel: json['security_level'] as String,
      fileName: json['file_name'] as String,
      fileSize: json['file_size'] as int,
      secureViewUrl: json['secure_view_url'] as String,
      secureDownloadUrl: json['secure_download_url'] as String,
      uploadedBy: json['uploaded_by'] as int,
      orderInGroup: json['order_in_group'] as int?,
      createdAt: json['created_at'] as String,
      isActive: json['is_active'] as bool,
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
