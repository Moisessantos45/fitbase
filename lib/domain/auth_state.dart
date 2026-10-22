import 'package:fitbase/domain/auth_models.dart';

class AuthState {
  final bool authenticated;
  final bool loading;
  final AlertState alertMessage;
  final AuthUser? authData;
  final bool accountNotVerified;
  final bool requiresTwoFactor;
  final TotpData totpData;
  final String email;
  final String password;
  final String token;
  final bool suppressAutoRefresh;

  const AuthState({
    this.authenticated = false,
    this.loading = false,
    this.alertMessage = const AlertState(),
    this.authData,
    this.accountNotVerified = false,
    this.requiresTwoFactor = false,
    this.totpData = const TotpData(),
    this.email = '',
    this.password = '',
    this.token = '',
    this.suppressAutoRefresh = false,
  });

  AuthState copyWith({
    bool? authenticated,
    bool? loading,
    AlertState? alertMessage,
    AuthUser? authData,
    bool? accountNotVerified,
    bool? requiresTwoFactor,
    TotpData? totpData,
    String? email,
    String? password,
    String? token,
    bool? suppressAutoRefresh,
  }) {
    return AuthState(
      authenticated: authenticated ?? this.authenticated,
      loading: loading ?? this.loading,
      alertMessage: alertMessage ?? this.alertMessage,
      authData: authData ?? this.authData,
      accountNotVerified: accountNotVerified ?? this.accountNotVerified,
      requiresTwoFactor: requiresTwoFactor ?? this.requiresTwoFactor,
      totpData: totpData ?? this.totpData,
      email: email ?? this.email,
      password: password ?? this.password,
      token: token ?? this.token,
      suppressAutoRefresh: suppressAutoRefresh ?? this.suppressAutoRefresh,
    );
  }
}
