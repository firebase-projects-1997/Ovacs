
import 'space_account_model.dart';

class AllConnectionsResponse {
  final int totalFollowing;
  final int totalFollowers;
  final List<SpaceAccountModel> following;
  final List<SpaceAccountModel> followers;

  AllConnectionsResponse({
    required this.totalFollowing,
    required this.totalFollowers,
    required this.following,
    required this.followers,
  });

  factory AllConnectionsResponse.fromJson(Map<String, dynamic> json) {
    return AllConnectionsResponse(
      totalFollowing: json['total_following'] ?? 0,
      totalFollowers: json['total_followers'] ?? 0,
      following: (json['following'] as List<dynamic>?)
              ?.map((e) => SpaceAccountModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      followers: (json['followers'] as List<dynamic>?)
              ?.map((e) => SpaceAccountModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_following': totalFollowing,
      'total_followers': totalFollowers,
      'following': following.map((e) => e.toJson()).toList(),
      'followers': followers.map((e) => e.toJson()).toList(),
    };
  }
}
