import 'package:equatable/equatable.dart';
import 'user.dart';

class AuthResponse extends Equatable {
  final User user;
  final String token;
  final String tokenType;
  final int expiresIn;

  const AuthResponse({
    required this.user,
    required this.token,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      token: json['token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
    );
  }

  @override
  List<Object> get props => [user, token, tokenType, expiresIn];
}
