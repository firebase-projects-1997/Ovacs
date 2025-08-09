class MessageModel {
  final int id;
  final int account;
  final int caseId;
  final int sender;
  final String senderName;
  final String type;
  final String? caseTitle;
  final String? content;
  final String? voiceFile;
  final String? voiceFileUrl;
  final String? voiceSteamUrl;
  final DateTime createdAt;
  final bool isActive;

  MessageModel({
    required this.id,
    required this.account,
    required this.caseId,
    required this.sender,
    required this.senderName,
    required this.type,
    this.caseTitle,
    this.content,
    this.voiceFile,
    this.voiceFileUrl,
    required this.createdAt,
    required this.isActive,this.voiceSteamUrl
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      account: json['account'],
      caseId: json['case'],
      sender: json['sender'],
      senderName: json['sender_name'],
      caseTitle: json['case_title'],
      type: json['type'],
      content: json['content'],
      voiceFile: json['voice_file'],
      voiceFileUrl: json['voice_file_url'],
      voiceSteamUrl: json['voice_stream_url'],
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account': account,
      'case': caseId,
      'sender': sender,
      'sender_name': senderName,
      'case_title': caseTitle,
      'type': type,
      'content': content,
      'voice_file': voiceFile,
      'voice_file_url': voiceFileUrl,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
      'voice_stream_url':voiceSteamUrl
    };
  }

  MessageModel copyWith({
    int? id,
    int? account,
    int? caseId,
    int? sender,
    String? senderName,
    String? caseTitle,
    String? type,
    String? content,
    String? voiceFile,
    String? voiceFileUrl,
    DateTime? createdAt,
    bool? isActive,
    String? voiceSteamUrl
  }) {
    return MessageModel(
      id: id ?? this.id,
      account: account ?? this.account,
      caseId: caseId ?? this.caseId,
      sender: sender ?? this.sender,
      senderName: senderName ?? this.senderName,
      caseTitle: caseTitle ?? this.caseTitle,
      type: type ?? this.type,
      content: content ?? this.content,
      voiceFile: voiceFile ?? this.voiceFile,
      voiceFileUrl: voiceFileUrl ?? this.voiceFileUrl,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      voiceSteamUrl: voiceSteamUrl ?? this.voiceSteamUrl
    );
  }
}
