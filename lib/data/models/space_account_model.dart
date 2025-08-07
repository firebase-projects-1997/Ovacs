class SpaceAccountModel {
  final int id;
  final String name;
  final String relationship;
  final bool canSwitchTo;
  final DateTime? connectedSince;

  const SpaceAccountModel({
    required this.id,
    required this.name,
    required this.relationship,
    required this.canSwitchTo,
    this.connectedSince,
  });

  factory SpaceAccountModel.fromJson(Map<String, dynamic> json) {
    return SpaceAccountModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? '',
      canSwitchTo: json['can_switch_to'] ?? false,
      connectedSince: json['connected_since'] != null
          ? DateTime.tryParse(json['connected_since'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'can_switch_to': canSwitchTo,
      'connected_since': connectedSince?.toUtc().toIso8601String(),
    };
  }
}
