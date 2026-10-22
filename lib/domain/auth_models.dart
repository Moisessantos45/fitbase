class AlertState {
  final bool error;
  final String msg;

  const AlertState({
    this.error = false,
    this.msg = '',
  });

  AlertState copyWith({
    bool? error,
    String? msg,
  }) {
    return AlertState(
      error: error ?? this.error,
      msg: msg ?? this.msg,
    );
  }
}

class TotpData {
  final String uri;
  final String secret;

  const TotpData({
    this.uri = '',
    this.secret = '',
  });

  TotpData copyWith({
    String? uri,
    String? secret,
  }) {
    return TotpData(
      uri: uri ?? this.uri,
      secret: secret ?? this.secret,
    );
  }
}

class AuthUser {
  final int id;
  final int roleId;
  final String email;
  final bool twoFactorEnabled;
  final bool firstSession;
  final bool fullProfile;
  final bool emailConfirmed;
  final bool active;
  final String token;
  final String createdAt;
  final String updatedAt;

  const AuthUser({
    this.id = 0,
    this.roleId = 0,
    this.email = '',
    this.twoFactorEnabled = false,
    this.firstSession = false,
    this.fullProfile = false,
    this.emailConfirmed = false,
    this.active = false,
    this.token = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  AuthUser copyWith({
    int? id,
    int? roleId,
    String? email,
    bool? twoFactorEnabled,
    bool? firstSession,
    bool? fullProfile,
    bool? emailConfirmed,
    bool? active,
    String? token,
    String? createdAt,
    String? updatedAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      email: email ?? this.email,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      firstSession: firstSession ?? this.firstSession,
      fullProfile: fullProfile ?? this.fullProfile,
      emailConfirmed: emailConfirmed ?? this.emailConfirmed,
      active: active ?? this.active,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isUser => roleId == 1;
  bool get isOwner => roleId == 2;
  bool get isGymManager => roleId == 3;
  bool get isAdmin => roleId == 4;
}
