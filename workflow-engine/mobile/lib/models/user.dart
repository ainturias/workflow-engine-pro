class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? departmentId;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.departmentId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? '',
      departmentId: json['departmentId'],
    );
  }

  String get fullName => '$firstName $lastName';

  String get roleLabel {
    switch (role) {
      case 'ADMIN':
        return 'Administrador';
      case 'DISEÑADOR':
        return 'Diseñador';
      case 'FUNCIONARIO':
        return 'Funcionario';
      case 'CLIENTE':
        return 'Cliente';
      default:
        return role;
    }
  }
}

class AuthResponse {
  final String token;
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? departmentId;

  AuthResponse({
    required this.token,
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.departmentId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? '',
      departmentId: json['departmentId'],
    );
  }

  User toUser() {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      departmentId: departmentId,
    );
  }
}
