class UserProfile {
  final int id;
  final int authId;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String avatarUrl;

  const UserProfile({
    this.id = 0,
    this.authId = 0,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.email = '',
    this.avatarUrl = '',
  });

  UserProfile copyWith({
    int? id,
    int? authId,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
