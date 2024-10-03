class UserInfo {
  final String id;
  final String? nickname;
  final String? profileImageUrl;
  final String? email;

  UserInfo({
    required this.id,
    this.nickname,
    this.profileImageUrl,
    this.email,
  });

  @override
  String toString() {
    return 'UserInfo{id: $id, nickname: $nickname, profileImageUrl: $profileImageUrl, email: $email}';
  }
}