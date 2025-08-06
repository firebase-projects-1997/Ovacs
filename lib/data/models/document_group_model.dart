class DocumentGroupModel {
  final int id;
  final int account;
  final String sessionTitle;
  final String name;
  final String description;

  DocumentGroupModel({
    required this.id,
    required this.account,
    required this.sessionTitle,
    required this.name,
    required this.description,
  });

  factory DocumentGroupModel.fromJson(Map<String, dynamic> json) {
    return DocumentGroupModel(
      id: json['id'],
      account: json['account'],
      sessionTitle: json['session_title'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account': account,
      'session_title': sessionTitle,
      'name': name,
      'description': description,
    };
  }
}
